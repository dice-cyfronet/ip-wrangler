require './ipt_nat'
require './ipt_ip'
require './ipt_db'

require 'sinatra'
require 'json'

require 'logger'
require 'yaml'

trap('SIGINT') do
  puts 'SIGINT'
end

unless File.file?('config.yml')
  puts 'No config.yml file found.'
  exit(1)
end

$config = YAML.load_file('config.yml')

puts 'Check database'

db = Sequel.connect('sqlite://' + $config[:db])

db.create_table? :nat_ports do
  primary_key :id
  String :public_ip
  Int :public_port
  String :private_ip
  Int :private_port
  String :protocol
end

db.create_table? :nat_ips do
  primary_key :id
  String :public_ip
  String :private_ip
end

db.disconnect

$logger = Logger.new($config[:log_file])

command = Command.new_chain($config[:iptables_chain], 'nat')
`#{$config[:iptables_path]} #{command}`

command = Command.append_rule('PREROUTING', 'nat', Rule.new([Parameter.jump($config[:iptables_chain])]))
`#{$config[:iptables_path]} #{command}`

$nat = NAT.new(range_ports($config[:port_start], $config[:port_stop], parse_ip($config[:port_ip]), 'tcp') +
                   range_ports($config[:port_start], $config[:port_stop], parse_ip($config[:port_ip]), 'udp'),
               [], $config[:db], $logger, $config[:iptables_path], $config[:iptables_chain])

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

get '/' do
  sandbox do
    204
  end
end

get '/free/port' do
  sandbox do
    $nat.free_ports.to_json
  end
end

get '/free/ip' do
  sandbox do
    $nat.free_ips.to_json
  end
end

# List any NAT port(s)
get '/nat/port' do
  sandbox do
    $nat.nat_ports.to_json
  end
end

# List NAT port(s) for specified private IP
get '/nat/port/*' do |private_ip|
  sandbox do
    private_ip = parse_ip(private_ip)
    $nat.nat_ports.select { |nat_port| nat_port.private_ip == private_ip }.to_json
  end
end

# Create NAT port(s) for specified IP
post '/nat/port/*/*/*' do |private_ip, private_port, protocol|
  sandbox do
    public_ip_port = $nat.lock_ip_port(Port.new(parse_ip(private_ip), private_port, protocol))

    if public_ip_port != nil
      public_ip_port.to_json
    else
      404
    end
  end
end

# Create NAT port(s) for specified IP
post '/nat/port/*/*' do |private_ip, private_port|
  sandbox do
    public_ip_port_tcp = $nat.lock_ip_port(Port.new(parse_ip(private_ip), private_port, 'tcp'))
    public_ip_port_udp = $nat.lock_ip_port(Port.new(parse_ip(private_ip), private_port, 'udp'))

    if public_ip_port_tcp != nil and public_ip_port_udp != nil
      "[#{public_ip_port_tcp.to_json},#{public_ip_port_udp.to_json}]"
    else
      404
    end
  end
end

# Delete NAT port with specified protocol for specified IP
delete '/nat/port/*/*/*' do |private_ip, private_port, protocol|
  sandbox do
    free_port = $nat.free_ip_port(parse_ip(private_ip), private_port, protocol)

    if free_port.length > 0
      204
    else
      404
    end
  end
end

# Delete NAT port with any protocol (TCP and UDP) for specified IP
delete '/nat/port/*/*' do |private_ip, private_port|
  sandbox do
    free_port = $nat.free_ip_port(parse_ip(private_ip), private_port)

    if free_port.length > 0
      204
    else
      404
    end
  end
end

# Delete any NAT ports for specified IP
delete '/nat/port/*' do |private_ip|
  sandbox do
    free_port = $nat.free_ip_port(parse_ip(private_ip))

    if free_port.length > 0
      204
    else
      404
    end
  end
end

# List any NAT IP(s)
get '/nat/ip' do
  sandbox do
    $nat.nat_ips.to_json
  end
end

# List NAT IP(s) for specified private IP
get '/nat/ip/*' do |private_ip|
  sandbox do
    $nat.nat_ips.select { |nat_ip| nat_ip.private_ip == private_ip }.to_json
  end
end

# Create NAT IP for specified private IP
post '/nat/ip/*' do |private_ip|
  sandbox do
    public_ip = $nat.lock_ip(IP.new(parse_ip(private_ip)))

    if public_ip != nil
      public_ip.to_json
    else
      404
    end
  end
end

# Delete NAT specified IP for specified IP
delete '/nat/ip/*/*' do |private_ip, public_ip|
  sandbox do
    free_ip = $nat.free_ip(IP.new(parse_ip(private_ip)), IP.new(parse_ip(public_ip)))

    if free_ip.length > 0
      204
    else
      404
    end
  end
end

# Delete NAT any IP(s) for specified IP
delete '/nat/ip/*' do |private_ip|
  sandbox do
    free_ip = $nat.free_ip(IP.new(parse_ip(private_ip)))

    if free_ip.length > 0
      204
    else
      404
    end
  end
end
