require 'rubygems'
require 'sequel'

require './ipt_nat'

class DB

  def initialize(db_name, logger)
    @db = Sequel.connect('sqlite://' + db_name)
    @logger = logger
  end

  def insert_nat_ip_port(public_ip, public_port, private_ip, private_port, protocol)
    @db[:nat_ports].insert(:public_ip => public_ip, :public_port => public_port,
                           :private_ip => private_ip, :private_port => private_port, :protocol => protocol)
    @logger.info "Insert nat ip port entry: #{public_ip}/#{public_port} -> #{private_ip}/#{private_port} (#{protocol})"
  end

  def delete_nat_ip_port(private_ip, private_port, protocol)
    @db[:nat_ports].where(:private_ip => private_ip, :private_port => private_port,
                          :protocol => protocol).delete
    @logger.info "Delete nat ip port entry: #{private_ip}/#{private_port} (#{protocol})"
  end

  def insert_nat_ip(public_ip, private_ip)
    @db[:nat_ips].insert(:public_ip => public_ip, :private_ip => private_ip)
    @logger.info "Insert nat ip entry: #{public_ip} -> #{private_ip}"
  end

  def delete_nat_ip(private_ip, public_ip)
    @db[:nat_ips].where(:private_ip => private_ip, :public_ip => public_ip).delete
    @logger.info "Delete nat ip entry: #{public_ip}"
  end

  def load_from_db
    nat_ports = []
    @db[:nat_ports].each do |row|
      nat_ports.push(NATPort.new(parse_ip(row[:public_ip]), parse_ip(row[:private_ip]),
                                 row[:public_port], row[:private_port], row[:protocol]))
    end

    nat_ips = []
    @db[:nat_ips].each do |row|
      nat_ips.push(NATIP.new(parse_ip(row[:public_ip]), parse_ip(row[:private_ip])))
    end

    return nat_ports, nat_ips
  end

end

def init
  db = Sequel.connect('sqlite://ipt.db')

  db.create_table :nat_ports do
    primary_key :id
    String :public_ip
    Int :public_port
    String :private_ip
    Int :private_port
    String :protocol
  end

  db.create_table :nat_ips do
    primary_key :id
    String :public_ip
    String :private_ip
  end
end