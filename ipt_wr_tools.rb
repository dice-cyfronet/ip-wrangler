module IPTWr
  class IPAddress

    attr_accessor :ip_octets

    def initialize(ip)
      if ip.nil?
        @ip_octets = nil
      elsif ip.instance_of? self.class
        @ip_octets = ip.ip_octets
      elsif p.instance_of? String
        ip_octets_s = ip.split '.'
        raise 'Illegal IP format (octets count)' if ip_octets_s.length != 4
        @ip_octets = Array.new(4) { 0 }
        i = 0
        ip_octets_s.each do |o|
         Integer(o) rescue raise 'Illegal IP format (NaN)'
         @ip_octets[i] = o.to_i
         raise 'Illegal IP format (out of range)' if @ip_octets[i] < 0 or @ip_octets[i] > 255
         i = i + 1
        end
      else
        raise 'Wrong format'
      end
    end

    def to_s
      if @ip_octets.nil?
        'NULL'
      else
        "#{@ip_octets[0]}.#{@ip_octets[1]}.#{@ip_octets[2]}.#{@ip_octets[3]}"
      end
    end
  end

  class Port
    attr_accessor :port

    def initialize(p)
      if p.nil?
        @port = nil
      else
        raise 'Port out of range' if p < 0 or p > 65535
        @port = p
      end
    end

    def to_s
      if p.nil?
        'NULL'
      else
        "#{p}"
      end
    end
  end

  class Protocol
    attr_accessor :protocol
    PROTO_TCP = 0
    PROTO_UDP = 1

    def initialize(protocol)
      raise 'Unknown protocol' if proto < PROTO_TCP or proto > PROTO_UDP
      @protocol = protocol
    end
  end

  class PortRange
    attr_accessor :proto, :b, :e

    def each
      b_port = @b.port
      e_port = @e.port
      b_port.step(e_port, 1) { |p| yield p }
    end

    def initialize(proto, b, e)
      raise 'Ports order mismatch' if b > e
      @proto = Protocol.new proto
      @b = Port.new b
      @e = Port.new e
    end
  end

  class NatPort
    attr_accessor :priv_ip, :pub_ip, :priv_port, :pub_port, :protocol

    def initialize(priv_ip, pub_ip, priv_port, pub_port, protocol)
      @priv_ip = IPAddress.new priv_ip
      @pub_ip = IPAddress.new pub_ip
      @priv_port = Port.new priv_port
      @pub_port = Port.new pub_port
      @protocol = Protocol.new protocol
    end
  end

  class NatPorts

    def initialize
      @nat_ports = Array.new
    end

    def db_load(db)

    end

    # @param [PortRange] pr
    def add_range(ip, pr)
      proto = pr.proto
      pr.each do |p|
        np = NatPort.new nil,ip,nil,p,proto
        @nat_ports.push np
      end
    end

  end

end