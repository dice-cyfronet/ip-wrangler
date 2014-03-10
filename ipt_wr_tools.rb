require 'sqlite3'

module IptWr

  class Database

    def initialize(db_name)
      @db = nil
      @db = SQLite3::Database.new(db_name)
    end

    def create
      raise 'Uninitialized' if @db.nil?
      @db.execute('CREATE TABLE IF NOT EXISTS NatPorts (pubIp TEXT NOT NULL, pubPort INT NOT NULL, privIp TEXT DEFAULT NULL, privPort INT DEFAULT NULL, proto TEXT DEFAULT NULL, created TIMESTAMP DEFAULT CURRENT_TIMESTAMP)')
    end

    def save_nat_port(np)
      @db.execute('INSERT INTO NatPorts (pubIp, pubPort, privIp, privPort, proto) VALUES (?, ?, ?, ?, ?)',
                 np.pub_ip.to_s, np.pub_port.to_s, np.priv_ip.to_s, np.priv_port.to_s,
                 np.protocol.to_s)
    end

    def load_nat_ports
      nps = NatPorts.new
      nprs = @db.execute('SELECT pubIp, pubPort, privIp, privPort, proto FROM NatPorts')
      nprs.each do |npr|
        case npr[4]
          when 'tcp'
            proto = Protocol::PROTO_TCP
          when 'udp'
            proto = Protocol::PROTO_UDP
          else
            raise 'Unknown protocol'
        end
        np = NatPort.new npr[2],npr[0],npr[3],npr[1],proto
        nps.add_nat_port np
      end
      nps
    end

  end


  class IPAddress

    attr_accessor :ip_octets

    def initialize(ip)
      if ip.nil?
        @ip_octets = nil
      elsif ip.instance_of? self.class
        @ip_octets = ip.ip_octets
      elsif ip.instance_of? String
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
        raise "Wrong format #{ip.class}"
      end
    end

    def to_s
      if @ip_octets.nil?
        nil
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
      if @port.nil?
        nil
      else
        "#{@port}"
      end
    end
  end

  class Protocol
    attr_accessor :protocol
    PROTO_TCP = 0
    PROTO_UDP = 1

    def initialize(protocol)
      raise 'Unknown protocol' if protocol < PROTO_TCP or protocol > PROTO_UDP
      @protocol = protocol
    end

    def to_s
      case @protocol
        when PROTO_TCP
          'tcp'
        when PROTO_UDP
          'udp'
        else
          raise 'Unknown protocol'
      end
    end
  end

  #class PortRange
  #  attr_accessor :proto, :b, :e

  #  def each
  #    b_port = @b.port
  #    e_port = @e.port
  #    b_port.step(e_port, 1) { |p| yield p }
  #  end

  #  def initialize(proto, b, e)
  #    raise 'Ports order mismatch' if b > e
  #    @proto = Protocol.new proto
  #    @b = Port.new b
  #    @e = Port.new e
  #  end
  # end

  class NatPort
    attr_accessor :priv_ip, :pub_ip, :priv_port, :pub_port, :protocol

    def initialize(priv_ip, pub_ip, priv_port, pub_port, protocol)
      @priv_ip = IPAddress.new priv_ip
      @pub_ip = IPAddress.new pub_ip
      @priv_port = Port.new priv_port
      @pub_port = Port.new pub_port
      @protocol = Protocol.new protocol
    end

    def db_save(db)
      db.save_nat_port self
    end
  end

  class NatPorts

    def initialize
      @nat_ports = Array.new
    end

    def db_load(db)

    end

    def add_range(ip, proto, p1, p2)
      raise 'Ports order mismatch' if p1 > p2
      p1.step(p2,1) do |p|
        np = NatPort.new nil,ip,nil,p,proto
        @nat_ports.push np
      end
    end

    def add_nat_port(np)
      @nat_ports.push np
    end

    def db_save(db)
      @nat_ports.each do |p|
        p.db_save db
      end
    end

  end

end