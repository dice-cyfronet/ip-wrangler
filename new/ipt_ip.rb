class IP
  attr_accessor :ip

  def initialize(ip)
    @ip = ip
  end

  def to_s
    "IP: #{@ip[0]}.#{@ip[1]}.#{@ip[2]}.#{@ip[3]}"
  end

  def to_s_ip
    "#{@ip[0]}.#{@ip[1]}.#{@ip[2]}.#{@ip[3]}"
  end
end

class Port < IP
  attr_accessor :port, :protocol


  def initialize(ip, port, protocol)
    super(ip)
    @port = port
    @protocol = protocol
  end

  def to_s
    "Port: #{@ip[0]}.#{@ip[1]}.#{@ip[2]}.#{@ip[3]}:#{@port}/#{@protocol}"
  end
end

def parse_ip(ip)
  ip.split(/\./).map { |octet| octet.to_i }
end

def str_ip(ip)
  "#{ip[0]}.#{ip[1]}.#{ip[2]}.#{ip[3]}"
end

def validate_ip(ip)
  ip.select { |octet| octet < 0 or octet > 255 }.length == 0
end

def range_ips(start, stop)
  if validate_ip(start) and validate_ip(stop)
    start = start.inject { |sum, octet| sum * 256 + octet }
    stop = stop.inject { |sum, octet| sum * 256 + octet }

    (start..stop).map do |ip|
      IP.new([(ip/16777216) % 256, (ip/65536) % 256, (ip/256) % 256, ip % 256])
    end
  end
end

def validate_port(port)
  port > 0 and port < 65536
end

def range_ports(start, stop, ip, protocol)
  (start..stop).map { |port| Port.new(ip, port, protocol) }
end