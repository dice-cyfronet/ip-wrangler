$config = YAML.load_file('config.yml')

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

get '/' do
  sandbox do
    204
  end
end

# List any NAT port(s)
get '/nat/port' do
  sandbox do
    $nat.get_nat_ports.to_json
  end
end

# List NAT port(s) for specified private IP
get '/nat/port/*' do |private_ip|
  sandbox do
    $nat.get_nat_ports(private_ip).to_json
  end
end

# List any NAT IP(s)
get '/nat/ip' do
  sandbox do
    $nat.get_nat_ips.to_json
  end
end

# List NAT IP(s) for specified private IP
get '/nat/ip/*' do |private_ip|
  sandbox do
    $nat.get_nat_ips(private_ip).to_json
  end
end

# Create NAT port(s) for specified IP
post '/nat/port/*/*/*' do |private_ip, private_port, protocol|
  sandbox do
    public_ip_port = $nat.lock_port private_ip, private_port, protocol

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
    public_ip_port_tcp = $nat.lock_port private_ip, private_port, 'tcp'
    public_ip_port_udp = $nat.lock_port private_ip, private_port, 'udp'

    if public_ip_port_tcp != nil and public_ip_port_udp != nil
      "[#{public_ip_port_tcp.to_json},#{public_ip_port_udp.to_json}]"
    else
      404
    end
  end
end

# Create NAT IP for specified private IP
post '/nat/ip/*' do |private_ip|
  sandbox do
    public_ip = $nat.lock_ip private_ip

    if public_ip != nil
      public_ip.to_json
    else
      404
    end
  end
end

# Delete NAT port with specified protocol for specified IP
delete '/nat/port/*/*/*' do |private_ip, private_port, protocol|
  sandbox do
    released_port = $nat.release_port private_ip, private_port, protocol

    if released_port.length > 0
      204
    else
      404
    end
  end
end

# Delete NAT port with any protocol (TCP and UDP) for specified IP
delete '/nat/port/*/*' do |private_ip, private_port|
  sandbox do
    released_port = $nat.release_port private_ip, private_port

    if released_port.length > 0
      204
    else
      404
    end
  end
end

# Delete any NAT ports for specified IP
delete '/nat/port/*' do |private_ip|
  sandbox do
    released_port = $nat.release_port private_ip

    if released_port.length > 0
      204
    else
      404
    end
  end
end

# Delete NAT IP for specified IP
delete '/nat/ip/*/*' do |private_ip, public_ip|
  sandbox do
    released_ip = $nat.release_ip private_ip, public_ip

    if released_ip.length > 0
      204
    else
      404
    end
  end
end

# Delete NAT any IP(s) for specified IP
delete '/nat/ip/*' do |private_ip|
  sandbox do
    released_ip = $nat.release_ip private_ip

    if released_ip.length > 0
      204
    else
      404
    end
  end
end

# OLD API (compatibility)

get '/' do
  'IptWr REST Endpoint!'
end

get '/dnat' do
  sandbox do
    $nat.get_nat_ports.to_json
  end
end

get '/dnat/*' do |ip|
  sandbox do
    $nat.get_nat_ports(ip).to_json
  end
end

post '/dnat/*' do |ip|
  sandbox do
    redirects = []

    request.body.rewind
    data = JSON.parse request.body.read

    data.each do |dpp|
      redirects.push $nat.lock_port ip, dpp['port'], dpp['proto']
    end

    if redirects.length > 0
      redirects.to_json
    else
      404
    end
  end
end

delete '/dnat/*/*/*' do |ip, port, proto|
  sandbox do
    released_port = $nat.release_port ip, port, proto

    if released_port.length > 0
      204
    else
      404
    end
  end
end

delete '/dnat/*/*' do |ip, port|
  sandbox do
    released_port = $nat.release_port ip, port

    if released_port.length > 0
      204
    else
      404
    end
  end
end

delete '/dnat/*' do |ip|
  sandbox do
    released_port = $nat.release_port ip

    if released_port.length > 0
      204
    else
      404
    end
  end
end