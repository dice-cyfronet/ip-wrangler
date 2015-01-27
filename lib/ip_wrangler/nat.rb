module IpWrangler
  class NAT
    $lsof_bin_path = '/usr/bin/sudo /usr/bin/lsof'

    def initialize(config, db_name, chain_name, logger)
      @config = config
      @db = DB.new(db_name, logger)
      @iptables = Iptables.new(chain_name, logger)
      @logger = logger

      @db.select_nat_port.each do |nat_port|
        @iptables.append_nat_port nat_port[:public_ip], nat_port[:public_port],
                                  nat_port[:private_ip], nat_port[:private_port],
                                  nat_port[:protocol]
      end
      @db.select_nat_ip.each do |nat_ip|
        @iptables.append_nat_ip nat_ip[:public_ip], nat_ip[:private_ip]
      end
    end

    def not_used_port?(public_ip, public_port, protocol)
      output = IpWrangler::Exec.execute_command "#{$lsof_bin_path} -i #{protocol}@#{public_ip}:#{public_port}"
      output.empty?
    end

    def not_used_ip?(public_ip)
      output = "#{$lsof_bin_path} -i @#{public_ip}"
      output.empty?
    end

    def find_port(private_ip, private_port, protocol)
      port = @db.get_first_empty_nat_port protocol
      if port
        public_port = port[:public_port]
        return @config[:port_ip], public_port if not_used_port? @config[:port_ip], public_port, protocol and
            @iptables.not_exists_nat_port? @config[:port_ip], public_port, protocol, private_ip, private_port
      end
      nil
    end

    def find_ip(private_ip)
      ip = @db.get_first_empty_nat_ip
      if ip
        public_ip = ip[:public_ip]
        return public_ip if not_used_ip? public_ip && @iptables.not_exists_nat_ip? public_ip, private_ip
      end
      nil
    end

    def get_nat_ports(private_ip = nil)
      @db.select_nat_port private_ip
    end

    def get_nat_ips(private_ip = nil)
      @db.select_nat_ip private_ip
    end

    def lock_port(private_ip, private_port, protocol)
      port = @db.select_nat_port private_ip, private_port, protocol
      if port.empty?
        public_ip, public_port = find_port private_ip, private_port, protocol
        if public_ip && public_port
          @db.insert_nat_port public_ip, public_port, private_ip, private_port, protocol
          @iptables.append_nat_port public_ip, public_port, private_ip, private_port, protocol
          {:public_ip => public_ip, :public_port => public_port, :protocol => protocol,
           :private_ip => private_ip, :private_port => private_port}
        end
      else
        port = port.to_a[0]
        {:public_ip => port[:public_ip], :public_port => port[:public_port], :protocol => port[:protocol],
         :private_ip => private_ip, :private_port => private_port}
      end
    end

    def lock_ip(private_ip)
      ip = @db.select_nat_ip private_ip
      if ip.empty?
        public_ip = find_ip private_ip
        if public_ip
          @db.insert_nat_ip public_ip, private_ip
          @iptables.append_nat_ip public_ip, private_ip
          {:public_ip => public_ip,
           :private_ip => private_ip}
        end
      else
        ip = ip.to_a[0]
        {:public_ip => ip[:public_ip],
         :private_ip => private_ip}
      end
    end

    def release_port(private_ip, private_port = nil, protocol = nil)
      released_port = []
      @db.select_nat_port(private_ip, private_port, protocol).each do |nat_port|
        @iptables.delete_nat_port nat_port[:public_ip], nat_port[:public_port],
                                  nat_port[:private_ip], nat_port[:private_port],
                                  nat_port[:protocol]
        released_port.push({:public_ip => nat_port[:public_ip], :public_port => nat_port[:public_port],
                            :private_ip => nat_port[:private_ip], :private_port => nat_port[:private_port],
                            :protocol => nat_port[:protocol]})
      end
      @db.delete_nat_port private_ip, private_port, protocol
      released_port
    end

    def release_ip(private_ip, public_ip = nil)
      released_ip = []
      @db.select_nat_ip(private_ip, public_ip).each do |nat_ip|
        @iptables.delete_nat_ip nat_ip[:public_ip], nat_ip[:private_ip]
        released_ip.push({:public_ip => nat_ip[:public_ip]})
      end
      @db.delete_nat_ip private_ip, public_ip
      released_ip
    end

  end
end
