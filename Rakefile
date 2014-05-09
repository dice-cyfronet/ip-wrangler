task :default => :install

task :install => [:gem, :configure]

task :gem do
  sh 'bundle install'
end

task :configure do
  if not File.file? 'src/config.yml'
    STDOUT.puts 'Username '
    username = STDIN.gets
    STDOUT.puts 'Password'
    password = STDIN.gets
    STDOUT.puts 'Public IP address used for NAT port '
    port_ip = STDIN.gets
    STDOUT.puts 'Begin of available port for NAT '
    port_start = STDIN.gets
    STDOUT.puts 'End of available port for NAT '
    port_stop = STDIN.gets
    STDOUT.puts 'Count of public IP used for NAT ip '
    ip_count = STDIN.gets
    ip_count = Integer(ip_count)
    STDOUT.puts 'Public IP used for NAT ip (each line) '
    ip = []
    while ip_count > 0 do
      ip << STDIN.gets
      ip_count = ip_count - 1
    end

    config_file = File.open('src/config.yml', 'w')

    config_file.write(":log_file_path: log/ipt_wr_app.log\n")
    config_file.write(":db_name: ipt.db\n")

    config_file.write(":username: #{username}")
    config_file.write(":password: #{password}")

    config_file.write(":iptables_chain_name: IPT_WR\n")

    config_file.write(":port_ip: #{port_ip}")
    config_file.write(":port_start: #{port_start}")
    config_file.write(":port_stop: #{port_stop}")

    config_file.write(":ip:\n")
    ip.each { |i| config_file.write("    - #{i}") }

    config_file.close()
  end
end

task :clean do
  sh '/sbin/iptables -w -t nat --delete PREROUTING --jump IPT_WR_PRE'
  sh '/sbin/iptables -w -t nat --delete POSTROUTING --jump IPT_WR_POST'
  sh '/sbin/iptables -w -t nat --flush IPT_WR_PRE'
  sh '/sbin/iptables -w -t nat --flush IPT_WR_POST'
  sh '/sbin/iptables -w -t nat --delete-chain IPT_WR_PRE'
  sh '/sbin/iptables -w -t nat --delete-chain IPT_WR_POST'
end

task :run do
  sh './run.sh'
end

task :rundevel do
  sh './devel-run.sh'
end