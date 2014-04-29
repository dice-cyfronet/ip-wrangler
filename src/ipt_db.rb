class DB

  def initialize(db_name, logger)
    @db = Sequel.connect('sqlite://' + db_name)
    @logger = logger
  end

  def select_nat_port(private_ip=nil, private_port=nil, protocol=nil)
    params = {:private_ip => private_ip, :private_port => private_port, :protocol => protocol}.select { |key, value| value != nil }
    @db[:nat_ports].where(params)
  end

  def select_nat_ip(private_ip=nil, public_ip=nil)
    params = {:private_ip => private_ip, :public_ip => public_ip}.select { |key, value| value != nil }
    @db[:nat_ips].where(params)
  end

  def insert_nat_port(public_ip, public_port, private_ip, private_port, protocol)
    @db[:nat_ports].insert(:public_ip => public_ip, :public_port => public_port,
                           :private_ip => private_ip, :private_port => private_port, :protocol => protocol)
    @logger.info "Insert nat ip port entry: #{public_ip}/#{public_port} -> #{private_ip}/#{private_port} (#{protocol})"
  end

  def insert_nat_ip(public_ip, private_ip)
    @db[:nat_ips].insert(:public_ip => public_ip, :private_ip => private_ip)
    @logger.info "Insert nat ip entry: #{public_ip} -> #{private_ip}"
  end

  def delete_nat_port(private_ip, private_port=nil, protocol=nil)
    params = {:private_ip => private_ip, :private_port => private_port, :protocol => protocol}.select { |key, value| value != nil }
    @db[:nat_ports].where(params).delete
    @logger.info "Delete nat ip port entry: #{private_ip}/#{private_port} (#{protocol})"
  end

  def delete_nat_ip(private_ip, public_ip=nil)
    params = {:private_ip => private_ip, :public_ip => public_ip}.select { |key, value| value != nil }
    @db[:nat_ips].where(params).delete
    @logger.info "Delete nat ip entry: #{public_ip}"
  end

  def exists_nat_port?(public_ip, public_port, protocol, private_ip, private_port)
    @db[:nat_ports].where(:public_ip => public_ip, :public_port => public_port,
                          :private_ip => private_ip, :private_port => private_port, :protocol => protocol).empty?
  end

  def exists_nat_ip?(public_ip, private_ip)
    @db[:nat_ips].where(:public_ip => public_ip, :private_ip => private_ip).empty?
  end

end