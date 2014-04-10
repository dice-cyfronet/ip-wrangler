require './ipt_ip'
require './ipt_db'
require './ipt_iptables'

class NAT
  attr_accessor :nat_ports, :nat_ips, :free_ports, :free_ips

  def initialize(free_ports, free_ips, db_name, logger, iptables, chain)
    @chain = chain
    @iptables = iptables
    @logger = logger
    @db = DB.new(db_name, logger)

    @nat_ports, @nat_ips = @db.load_from_db
    @free_ports, @free_ips = free_ports, free_ips

    @nat_ports.each do |nat_port|
      @free_ports = @free_ports.reject do |free_port|
        free_port.ip == nat_port.public_ip and free_port.port == nat_port.public_port and free_port.protocol == nat_port.protocol
      end
    end

    @nat_ips.each do |nat_ip|
      @free_ips = @free_ips.reject do |free_ip|
        free_ip.ip == nat_ip.public_ip
      end
    end
  end

  def lock_ip_port(private_port)
    public_port = @free_ports.select { |port| port.protocol == private_port.protocol }.shift
    @free_ports.delete(public_port)

    nat_port = nil
    if public_port != nil
      nat_port = NATPort.new(public_port.ip, private_port.ip, public_port.port, private_port.port, private_port.protocol)
      @nat_ports.push(nat_port)

      @db.insert_nat_ip_port(public_port.to_s_ip, public_port.port,
                             private_port.to_s_ip, private_port.port,
                             private_port.protocol)
      command = append_nat_ip_port(@chain, public_port.to_s_ip, public_port.port,
                                   private_port.to_s_ip, private_port.port,
                                   private_port.protocol)
      @logger.info "#{command}"
      `#{@iptables} #{command}`
    end
    nat_port
  end

  def free_ip_port(private_ip, private_port=nil, protocol=nil)
    free_port = []

    @nat_ports.each do |nat_port|
      if nat_port.private_ip == private_ip and
          (private_port == nil or nat_port.private_port == private_port) and
          (protocol == nil or nat_port.protocol == protocol)
        port = Port.new(nat_port.public_ip, nat_port.public_port, nat_port.protocol)
        @free_ports.push(port)
        free_port.push(port)

        @db.delete_nat_ip_port(str_ip(nat_port.private_ip), nat_port.private_port,
                               nat_port.protocol)
        command = delete_nat_ip_port(@chain, str_ip(nat_port.public_ip), nat_port.public_port,
                                     str_ip(nat_port.private_ip), nat_port.private_port,
                                     nat_port.protocol)
        @logger.info "#{command}"
        `#{@iptables} #{command}`
      end
    end

    @nat_ports = @nat_ports.reject do |nat_port|
      nat_port.private_ip == private_ip and
          (private_port == nil or nat_port.private_port == private_port) and
          (protocol == nil or nat_port.protocol == protocol)
    end

    free_port
  end

  def lock_ip(private_ip)
    public_ip = @free_ips.shift

    nat_ip = nil
    if public_ip != nil
      nat_ip = NATIP.new(public_ip.ip, private_ip.ip)
      @nat_ips.push(nat_ip)

      @db.insert_nat_ip(public_ip.to_s_ip, private_ip.to_s_ip)
      command = append_nat_ip(@chain, public_ip.to_s_ip, private_ip.to_s_ip)

      @logger.info "#{command}"
      `#{@iptables} #{command}`
    end
    nat_ip
  end

  def free_ip(private_ip, public_ip=nil)
    free_ip = []

    @nat_ips.each do |nat_ip|
      if nat_ip.private_ip == private_ip.ip and
          (public_ip == nil or nat_ip.public_ip == public_ip.ip)
        ip = IP.new(nat_ip.public_ip)
        @free_ips.push(ip)
        free_ip.push(ip)

        @db.delete_nat_ip(str_ip(nat_ip.private_ip), str_ip(nat_ip.public_ip))
        command = delete_nat_ip(@chain, str_ip(nat_ip.private_ip), str_ip(nat_ip.public_ip))

        @logger.info "#{command}"
        `#{@iptables} #{command}`
      end
    end

    @nat_ips = @nat_ips.reject do |nat_ip|
      nat_ip.private_ip == private_ip.ip and
          (public_ip == nil or nat_ip.public_ip == public_ip.ip)
    end

    free_ip
  end
end

class NATEntry
  attr_accessor :public_ip, :private_ip

  def initialize(public_ip, private_ip)
    @public_ip, @private_ip = public_ip, private_ip
  end
end

class NATPort < NATEntry
  attr_accessor :public_port, :private_port, :protocol

  def initialize(public_ip, private_ip, public_port, private_port, protocol)
    super(public_ip, private_ip)
    @public_port, @private_port, @protocol = public_port, private_port, protocol
  end

  def to_s
    "{'public_ip':'#{@public_ip}',
'private_ip':'#{@private_ip}',
'public_port':'#{@public_port}',
'private_port':'#{@private_port}',
'protocol':'#{@protocol}'}"
  end

  def to_json(*a)
    {:public_ip => @public_ip,
     :private_ip => @private_ip,
     :public_port => @public_port,
     :private_port => @private_port,
     :protocol => @protocol}.to_json(*a)
  end
end

class NATIP < NATEntry
  def to_s
    "{'public_ip':'#{@public_ip}',
'private_ip':'#{@private_ip}'}"
  end

  def to_json(*a)
    {:public_ip => @public_ip,
     :private_ip => @private_ip}.to_json(*a)
  end
end
