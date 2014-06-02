$lsof_bin_path = '/usr/bin/lsof'

class NAT

  def initialize(config, db_name, chain_name, logger)
    @config = config
    @db = DB.new(db_name, logger)
    @iptables = Iptables.new(chain_name, logger)
    @logger = logger

    @db.select_nat_port.each do |nat_port|
      @iptables.append_nat_port nat_port[:public_ip], nat_port[:public_port], nat_port[:private_ip], nat_port[:private_port], nat_port[:protocol]
    end
    @db.select_nat_ip.each do |nat_ip|
      @iptables.append_nat_ip nat_ip[:public_ip], nat_ip[:private_ip]
    end
  end

  def not_used_port?(public_ip, public_port, protocol)
    `#{$lsof_bin_path} -i #{protocol}@#{public_ip}:#{public_port}`.empty?
  end

  def not_used_ip?(public_ip)
    `#{$lsof_bin_path} -i @#{public_ip}`.empty?
  end

  def find_port(private_ip, private_port, protocol)
    10.times do
      public_port = rand(@config[:port_stop] - @config[:port_start]) + @config[:port_start]
      return @config[:port_ip], public_port if not_used_port? @config[:port_ip], public_port, protocol and
        @iptables.not_exists_nat_port? @config[:port_ip], public_port, protocol, private_ip, private_port
    end
    (@config[:port_start]..@config[:port_stop]).each do |public_port|
      return @config[:port_ip], public_port unless @db.not_exists_nat_port? @config[:port_ip], public_port, protocol, private_ip, private_port
    end
  end

  def find_ip(private_ip)
    10.times do
      public_ip = @config[:ip].shuffle.sample
      return public_ip if not_used_ip? public_ip and @iptables.not_exists_nat_ip? public_ip, private_ip
    end
    @config[:ip].each do |public_ip|
      return public_ip unless @db.not_exists_nat_ip? public_ip, private_ip
    end
  end

  def get_nat_ports(private_ip=nil)
    @db.select_nat_port private_ip
  end

  def get_nat_ips(private_ip=nil)
    @db.select_nat_ip private_ip
  end

  def lock_port(private_ip, private_port, protocol)
    port = @db.select_nat_port private_ip, private_port, protocol
    if port.empty?
      public_ip, public_port = find_port private_ip, private_port, protocol
      @db.insert_nat_port public_ip, public_port, private_ip, private_port, protocol
      @iptables.append_nat_port public_ip, public_port, private_ip, private_port, protocol
      {:public_ip => public_ip, :public_port => public_port, :protocol => protocol,
        :privPort => private_port, :pubIp => public_ip, :pubPort => public_port}
    else
      # FIXME(paoolo) move this to ipt_main.rb
      port.to_json
    end
  end

  def lock_ip(private_ip)
    ip = @db.select_nat_ip private_ip
    if ip.empty?
      public_ip = find_ip private_ip
      @db.insert_nat_ip public_ip, private_ip
      @iptables.append_nat_ip public_ip, private_ip
      {:public_ip => public_ip}
    else
      # FIXME(paoolo) move this to ipt_main.rb
      ip.to_json
    end
  end

  def release_port(private_ip, private_port=nil, protocol=nil)
    released_port = []
    @db.select_nat_port(private_ip, private_port, protocol).each do |nat_port|
      @iptables.delete_nat_port nat_port[:public_ip], nat_port[:public_port], nat_port[:private_ip], nat_port[:private_port], nat_port[:protocol]
      released_port.push({:public_ip => nat_port[:public_ip], :public_port => nat_port[:public_port]})
    end
    @db.delete_nat_port private_ip, private_port, protocol
    released_port
  end

  def release_ip(private_ip, public_ip=nil)
    released_ip = []
    @db.select_nat_ip(private_ip, public_ip).each do |nat_ip|
      @iptables.delete_nat_ip nat_ip[:public_ip], nat_ip[:private_ip]
      released_ip.push({:public_ip => nat_ip[:public_ip]})
    end
    @db.delete_nat_ip private_ip, public_ip
    released_ip
  end

end