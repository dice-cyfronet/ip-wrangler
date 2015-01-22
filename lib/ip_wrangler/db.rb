module IpWrangler
  class DB
    def initialize(db_name, logger)
      @db = Sequel.connect('sqlite://' + db_name)
      @logger = logger
    end

    def select_nat_port(private_ip=nil, private_port=nil, protocol=nil)
      params = {:private_ip => private_ip, :private_port => private_port, :protocol => protocol}.select { |key, value| value != nil }
      nat_ports = []
      @db[:nat_ports].where(params).each do |nat_port|
        if nat_port[:private_port] != nil and nat_port[:private_port] != nil
          nat_ports.push nat_port
        end
      end
      nat_ports
    end

    def select_nat_ip(private_ip=nil, public_ip=nil)
      params = {:private_ip => private_ip, :public_ip => public_ip}.select { |key, value| value != nil }
      nat_ips = []
      @db[:nat_ips].where(params).each do |nat_ip|
        if nat_ip[:private_ip] != nil
          nat_ips.push nat_ip
        end
      end
      nat_ips
    end

    def insert_nat_port(public_ip, public_port, private_ip, private_port, protocol)
      params = {:public_ip => public_ip, :public_port => public_port, :protocol => protocol}
      data = {:private_ip => private_ip, :private_port => private_port}
      @db[:nat_ports].where(params).update(data)
      @logger.info "Insert nat ip port entry: #{public_ip}/#{public_port} -> #{private_ip}/#{private_port} (#{protocol})"
    end

    def insert_nat_ip(public_ip, private_ip)
      params = {:public_ip => public_ip}
      data = {:private_ip => private_ip}
      @db[:nat_ips].where(params).update(data)
      @logger.info "Insert nat ip entry: #{public_ip} -> #{private_ip}"
    end

    def delete_nat_port(private_ip, private_port=nil, protocol=nil)
      params = {:private_ip => private_ip, :private_port => private_port, :protocol => protocol}.select { |key, value| value != nil }
      data = {:private_ip => nil, :private_port => nil}
      @db[:nat_ports].where(params).update(data)
      @logger.info "Delete nat ip port entry: #{private_ip}/#{private_port} (#{protocol})"
    end

    def delete_nat_ip(private_ip, public_ip=nil)
      params = {:private_ip => private_ip, :public_ip => public_ip}.select { |key, value| value != nil }
      data = {:private_ip => nil}
      @db[:nat_ips].where(params).update(data)
      @logger.info "Delete nat ip entry: #{public_ip}"
    end

    def get_first_empty_nat_port(protocol)
      params = {:private_ip => nil, :private_port => nil, :protocol => protocol}
      empty_nat_ports = @db[:nat_ports].where(params)
      if not empty_nat_ports.empty?
        return empty_nat_ports.to_a[0]
      end
      nil
    end
    
    def get_first_empty_nat_ip
      params = {:private_ip => nil}
      empty_nat_ips = @db[:nat_ips].where(params)
      if not empty_nat_ips.empty?
        return empty_nat_ips.to_a[0]
      end
      nil
    end
    
    def not_exists_nat_port?(public_ip, public_port, protocol, private_ip, private_port)
      @db[:nat_ports].where(:public_ip => public_ip, :public_port => public_port,
        :private_ip => private_ip, :private_port => private_port, :protocol => protocol).empty?
    end

    def not_exists_nat_ip?(public_ip, private_ip)
      @db[:nat_ips].where(:public_ip => public_ip, :private_ip => private_ip).empty?
    end
  end
end
