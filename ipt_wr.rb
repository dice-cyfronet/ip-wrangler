require 'sinatra'
require 'json'
require 'logger'
require 'sqlite3'
require 'yaml'

set :sim, true

$config = YAML.load_file('config.yml')

$l = Logger.new($config[:log_file])
$l.level = Logger::DEBUG

use Rack::Auth::Basic, 'Restricted Area' do |username, password|
  [username, password] == [$config[:username], $config[:password]]
end

begin
   $db = SQLite3::Database.new($config[:db])
rescue Exception => e
   $l.critical "Exception while accessing DB: #{e}:#{e.backtrace}"
   exit(1)
end

if settings.sim
  $l.info 'IptWr started (in simulation mode)'
else
  $l.info 'IptWr started (in real mode)'
end

def ip_ok?( ip )
(ip =~ /^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$/)?true:false
end  

def get_port_candidate

rand(64510) + 1025

end

def port_free? ( proto, port )
  `/usr/bin/sudo /usr/bin/lsof -i #{proto}:#{port}`.empty? and `/usr/bin/sudo /sbin/iptables -t nat -v -n -L PREROUTING | /usr/bin/awk '{print $10, $11}' | /bin/grep -i '^#{proto} dpt:#{port}$'`.empty?
end

def port_valid? ( port )
  (1..65535).include?(port)
end

def proto_valid? ( proto )
  proto =~ /^(tcp|udp)$/i?true:false
end

def get_pub_port ( proto )

10.times do
  spc = get_port_candidate
  return spc if port_free?(proto, spc)
end

raise 'No suitable source port found.'

end

def redirect_ports ( ip, tcp_p, udp_p )

redirect_a = Array.new

got_lock = false

10.times do
  begin
    $db.execute('BEGIN EXCLUSIVE TRANSACTION')
    got_lock = true
    break
  rescue SQLite3::BusyException
    $l.info 'DB in use by another thread - retrying'
    sleep 0.2
  rescue Exception => e
    raise e
  end
end

unless got_lock
  $l.error 'Cannot acquire lock on DB - giving up'
  raise 'DB Lock Timeout'
end

tcp_p.each do |tp|
	  
pub_port = get_pub_port('tcp')
$l.debug "IP: #{ip}, PubPort: #{pub_port}, PrivPort: #{tp}, Proto: tcp"

unless settings.sim

`/usr/bin/sudo /sbin/iptables -t nat -A PREROUTING -d #{$config[:nat_ip]}/32 -p tcp -m tcp --dport #{pub_port} -m comment --comment "IptWr-AUTO" -j DNAT --to-destination #{ip}:#{tp}`

raise Exception, "Command iptables failed!" unless $?.exitstatus == 0

end

$db.execute("INSERT INTO NatRules (pubIp, privIp, pubPort, privPort, proto) values ('#{$config[:nat_ip]}', '#{ip}', #{pub_port}, #{tp}, 'tcp')")

redirect_h = Hash.new
redirect_h['pubIp'] = $config[:nat_ip]
redirect_h['privIp'] = ip
redirect_h['pubPort'] = pub_port
redirect_h['privPort'] = tp
redirect_h['proto'] = 'tcp'
redirect_a.push(redirect_h)

end

udp_p.each do |up|
	  
pub_port = get_pub_port('udp')

unless settings.sim

`/usr/bin/sudo /sbin/iptables -t nat -A PREROUTING -d #{$config[:nat_ip]}/32 -p udp -m udp --dport #{pub_port} -m comment --comment "IptWr-AUTO" -j DNAT --to-destination #{ip}:#{up}`

raise Exception, 'Command iptables failed!' unless $?.exitstatus == 0

end

$l.debug "IP: #{ip}, SrcPort: #{pub_port}, DstPort: #{up}, Proto: udp"
$db.execute("INSERT INTO NatRules (pubIp, privIp, pubPort, privPort, proto) values ('#{$config[:nat_ip]}', '#{ip}', #{pub_port}, #{up}, 'udp')")

redirect_h = Hash.new
redirect_h['pubIp'] = $config[:nat_ip]
redirect_h['privIp'] = ip
redirect_h['pubPort'] = pub_port
redirect_h['privPort'] = up
redirect_h['proto'] = 'udp'
redirect_a.push(redirect_h)

end

$db.execute('COMMIT')

redirect_a

end

get '/' do
  'IptWr REST Endpoint!'
end

get '/dnat' do
  content_type 'application/json'
  begin
  ip_a = Array.new
  ip_l = $db.execute('SELECT privIp FROM NatRules')
  ip_l.each { |ip| ip_a.push(ip[0]) }
  ip_a.to_json
  
  rescue Exception => e
    	$l.error "Unresolved exception: #{e}:#{e.backtrace}"
	500
  end

end

get '/dnat/*' do |ip|
  content_type 'application/json'
  redirect_l = $db.execute('SELECT pubIp, pubPort, privPort, proto FROM NatRules WHERE privIp = :ipaddr', ':ipaddr' => "#{ip}")
  
  ip_a = Array.new

  redirect_l.each do |r|
    ip_h = Hash.new
    ip_h['pubIp'] = r[0]
    ip_h['privIp'] = ip
    ip_h['pubPort'] = r[1].to_i
    ip_h['privPort'] = r[2].to_i
    ip_h['proto'] = r[3]
	
    ip_a.push(ip_h)
  end

  ip_a.to_json
end

post '/dnat/*' do |ip|
 content_type 'application/json'
 begin

  raise 'Illegal IP format' unless ip_ok?(ip)
  $l.info "Redirection for #{ip}"
  request.body.rewind
  data = JSON.parse request.body.read

  raise 'Illegal input JSON format' unless data.kind_of?(Array)

  redirect_tcp = Array.new
  redirect_udp = Array.new
	
  data.each do |dpp|
    raise 'Illegal input JSON format' unless dpp.kind_of?(Hash)
    raise 'Protocol is missing' unless dpp.has_key?('proto')
    raise 'Port is missing' unless dpp.has_key?('port')
    raise 'Unsupported protocol' unless proto_valid?( dpp['proto'] )
    raise 'Illegal port format' unless port_valid?( dpp['port'] )

		proto = dpp['proto']
	  priv_port = dpp['port']

    redirect_tcp.push(priv_port) if proto == 'tcp'
	  redirect_udp.push(priv_port) if proto == 'udp'
  end

   ra = redirect_ports( ip, redirect_tcp, redirect_udp )

   ra.to_json

  rescue JSON::ParserError
    $l.error 'Error while parsing input'
    400
  rescue RuntimeError => e
    $l.error "#{e}"
    400
  rescue Exception => e
    $l.error "Unresolved exception: #{e}:#{e.backtrace}"
    500

  end
end

def delete_ip(ip, port = nil, proto = nil)

  raise 'Illegal IP format' unless ip_ok?(ip)
   
   unless port.nil?
    begin
      Integer(port)
    rescue ArgumentError
      raise 'Illegal port format'
    end
   end
   
   if not proto.nil? and not proto == 'tcp' and not proto == 'udp'
      raise 'Illegal protocol'
   end


   redirect_l = nil

   if port.nil? and proto.nil?
     $l.info "Deleting entries for IP: #{ip}"
     redirect_l = $db.execute('SELECT pubIp, pubPort, privPort, proto, rowid FROM NatRules WHERE privIp = :ipaddr',
                          ':ipaddr' => "#{ip}")
   elsif not port.nil? and proto.nil?
     $l.info "Deleting entries for IP: #{ip} , port: #{port}"
     redirect_l = $db.execute('SELECT pubIp, pubPort, privPort, proto, rowid FROM NatRules WHERE privIp = :ipaddr AND privPort = :port',
                          ':ipaddr' => "#{ip}", ':port' => "#{port}")
   elsif not port.nil? and not proto.nil? 
     $l.info "Deleting entries for IP: #{ip} , port: #{port} , protocol: #{proto}"
     redirect_l = $db.execute('SELECT pubIp, pubPort, privPort, proto, rowid FROM NatRules WHERE privIp = :ipaddr AND privPort = :port AND proto = :proto',
                          ':ipaddr' => "#{ip}", ':port' => "#{port}", ':proto' => "#{proto}")
   else
     raise 'No port number for given protocol'
   end
   
   redirect_l.each do |r|

     unless settings.sim
       `/usr/bin/sudo /sbin/iptables -t nat -D PREROUTING -d #{r[0]}/32 -p #{r[3]} -m #{r[3]} --dport #{r[1]} -m comment --comment "IptWr-AUTO" -j DNAT --to-destination #{ip}:#{r[2]}`
      raise Exception, 'Command iptables failed!' unless $?.exitstatus == 0
     end

    $db.execute('DELETE FROM NatRules WHERE rowid = :id', ':id' => "#{r[4]}")

   end
end

delete '/dnat/*/*/*' do |ip, port, proto|
 content_type 'application/json'
 begin
   delete_ip(ip, port, proto)
   204
   rescue RuntimeError => e
     $l.error "#{e}"
     400
   rescue Exception => e
     $l.error "Unresolved exception: #{e}:#{e.backtrace}"
     500
 end
 
end

delete '/dnat/*/*' do |ip, port|
 content_type 'application/json'
 begin
   delete_ip(ip, port)
   204
   rescue RuntimeError => e
     $l.error "#{e}"
     400
   rescue Exception => e
     $l.error "Unresolved exception: #{e}:#{e.backtrace}"
     500
 end

end

delete '/dnat/*' do |ip|
 content_type 'application/json'

 begin 
   delete_ip(ip)
   
    204
   rescue RuntimeError => e
     $l.error "#{e}"
     400
   rescue Exception => e
     $l.error "Unresolved exception: #{e}:#{e.backtrace}"
     500
 end

end

