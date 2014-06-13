$config = YAML.load_file('config.yml')

use Rack::Auth::Basic, 'Restricted Area' do |username, password|
  [username, password] == [$config[:username], $config[:password]]
end

if File.exist?($config[:log_file_path])
  File.delete($config[:log_file_path])
end
$logger = Logger.new($config[:log_file_path])

$nat = NAT.new($config, $config[:db_name], $config[:iptables_chain_name], $logger)

def sandbox(&block)
  begin
    content_type 'application/json'
    yield
  rescue RuntimeError => e
    str = "Runtime error: #{e}:#{e.backtrace}"
    puts str
    $logger.error str
    400
  rescue Exception => e
    str = "Unresolved exception: #{e}:#{e.backtrace}"
    puts str
    $logger.error str
    500
  end
end

def valid_ip?(ip)
  (ip =~ /^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$/) ? true : false
end

def valid_port?(port)
  (1..65535).include?(port)
end

def valid_protocol?(protocol)
  protocol =~ /^(tcp|udp)$/i ? true : false
end

# List any NAT port(s)
get '/nat/port' do
  sandbox do
    $nat.get_nat_ports.map { |nat_port|
      puts nat_port[:public_ip]
      nat_port[:public_ip] = $config[:ext_ip]
      nat_port
    }.to_json
  end
end

# List NAT port(s) for specified private IP
get '/nat/port/*' do |private_ip|
  sandbox do
    if valid_ip? private_ip
      $nat.get_nat_ports(private_ip).map { |nat_port|
        puts nat_port[:public_ip]
        nat_port[:public_ip] = $config[:ext_ip]
        nat_port
      }.to_json
    else
      500
    end
  end
end

# List any NAT IP(s)
get '/nat/ip' do
  sandbox do
    $nat.get_nat_ips.map { |nat_ip| nat_ip }.to_json
  end
end

# List NAT IP(s) for specified private IP
get '/nat/ip/*' do |private_ip|
  sandbox do
    if valid_ip? private_ip
      $nat.get_nat_ips(private_ip).map { |nat_ip| nat_ip }.to_json
    else
      500
    end
  end
end

# Create NAT port(s) for specified IP
post '/nat/port/*/*/*' do |private_ip, private_port, protocol|
  sandbox do
    private_port = private_port.to_i
    if valid_ip? private_ip and valid_port? private_port and valid_protocol? protocol
      public_ip_port = $nat.lock_port private_ip, private_port, protocol

      if public_ip_port != nil
        public_ip_port[:public_ip] = $config[:ext_ip]
        public_ip_port.to_json
      else
        404
      end
    else
      500
    end
  end
end

# Create NAT port(s) for specified IP
post '/nat/port/*/*' do |private_ip, private_port|
  sandbox do
    private_port = private_port.to_i
    if valid_ip? private_ip and valid_port? private_port
      public_ip_port_tcp = $nat.lock_port private_ip, private_port, 'tcp'
      public_ip_port_udp = $nat.lock_port private_ip, private_port, 'udp'

      out = nil

      if public_ip_port_tcp != nil
        public_ip_port_tcp[:public_ip] = $config[:ext_ip]
        out = "#{public_ip_port_tcp.to_json}"
      end

      if public_ip_port_udp != nil
        public_ip_port_udp[:public_ip] = $config[:ext_ip]
        if out != nil
          out += ",#{public_ip_port_udp.to_json}"
        else
          out = "#{public_ip_port_udp.to_json}"
        end
      end

      if out != nil
        out = "[#{out}]"
        out
      else
        404
      end
    else
      500
    end
  end
end

# Create NAT IP for specified private IP
post '/nat/ip/*' do |private_ip|
  sandbox do
    if valid_ip? private_ip
      public_ip = $nat.lock_ip private_ip

      if public_ip != nil
        public_ip.to_json
      else
        404
      end
    else
      500
    end
  end
end

# Delete NAT port with specified protocol for specified IP
delete '/nat/port/*/*/*' do |private_ip, private_port, protocol|
  sandbox do
    private_port = private_port.to_i
    if valid_ip? private_ip and valid_port? private_port and valid_protocol? protocol
      released_port = $nat.release_port private_ip, private_port, protocol

      if released_port.length > 0
        204
      else
        404
      end
    else
      500
    end
  end
end

# Delete NAT port with any protocol (TCP and UDP) for specified IP
delete '/nat/port/*/*' do |private_ip, private_port|
  sandbox do
    private_port = private_port.to_i
    if valid_ip? private_ip and valid_port? private_port
      released_port = $nat.release_port private_ip, private_port

      if released_port.length > 0
        204
      else
        404
      end
    else
      500
    end
  end
end

# Delete any NAT ports for specified IP
delete '/nat/port/*' do |private_ip|
  sandbox do
    if valid_ip? private_ip
      released_port = $nat.release_port private_ip

      if released_port.length > 0
        204
      else
        404
      end
    else
      500
    end
  end
end

# Delete NAT IP for specified IP
delete '/nat/ip/*/*' do |private_ip, public_ip|
  sandbox do
    if valid_ip? private_ip and valid_ip? public_ip
      released_ip = $nat.release_ip private_ip, public_ip

      if released_ip.length > 0
        204
      else
        404
      end
    else
      500
    end
  end
end

# Delete NAT any IP(s) for specified IP
delete '/nat/ip/*' do |private_ip|
  sandbox do
    if valid_ip? private_ip
      released_ip = $nat.release_ip private_ip

      if released_ip.length > 0
        204
      else
        404
      end
    else
      500
    end
  end
end

# OLD API (compatibility)

get '/' do
  'IptWr REST Endpoint!'
end

get '/dnat' do
  sandbox do
    $nat.get_nat_ports.map { |nat_port|
      nat_port[:public_ip] = $config[:ext_ip]
      nat_port[:privPort] = nat_port[:private_port]
      nat_port[:pubIp] = nat_port[:public_ip]
      nat_port[:pubPort] = nat_port[:public_port]
      nat_port
    }.to_json
  end
end

get '/dnat/*' do |ip|
  sandbox do
    if valid_ip? ip
      $nat.get_nat_ports(ip).map { |nat_port|
        nat_port[:public_ip] = $config[:ext_ip]
        nat_port[:privPort] = nat_port[:private_port]
        nat_port[:pubIp] = nat_port[:public_ip]
        nat_port[:pubPort] = nat_port[:public_port]
        nat_port
      }.to_json
    else
      500
    end
  end
end

post '/dnat/*' do |ip|
  sandbox do
    redirects = []

    request.body.rewind
    data = JSON.parse request.body.read

    if valid_ip? ip
      data.each do |dpp|
        if valid_port? dpp['port'] and valid_protocol? dpp['proto']
          redir = $nat.lock_port ip, dpp['port'], dpp['proto']
          if redir != nil
            redir[:public_ip] = $config[:ext_ip]
            redir[:privPort] = redir[:private_port]
            redir[:pubIp] = redir[:public_ip]
            redir[:pubPort] = redir[:public_port]
            redirects.push redir
          end
        end
      end

      if redirects.length > 0
        redirects.to_json
      else
        404
      end
    else
      500
    end
  end
end

delete '/dnat/*/*/*' do |ip, port, proto|
  sandbox do
    port = port.to_i
    if valid_ip? ip and valid_port? port and valid_protocol? proto
      released_port = $nat.release_port ip, port, proto

      if released_port.length > 0
        204
      else
        404
      end
    else
      500
    end
  end
end

delete '/dnat/*/*' do |ip, port|
  sandbox do
    port = port.to_i
    if valid_ip? ip and valid_port? port
      released_port = $nat.release_port ip, port

      if released_port.length > 0
        204
      else
        404
      end
    else
      500
    end
  end
end

delete '/dnat/*' do |ip|
  sandbox do
    if valid_ip? ip
      released_port = $nat.release_port ip

      if released_port.length > 0
        204
      else
        404
      end
    else
      500
    end
  end
end