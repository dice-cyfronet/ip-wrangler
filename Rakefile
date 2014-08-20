task :gem do
  sh 'bundle install --deployment'
end

task :configure do
  if not File.file? 'src/config.yml'
    STDOUT.puts 'Username '
    username = STDIN.gets
    STDOUT.puts 'Password'
    password = STDIN.gets
    STDOUT.puts 'External IP address user for NAT port (if your server is indicated by a different address than that assigned to the interface, enter it here) '
    ext_ip = STDIN.gets
    STDOUT.puts 'Public IP address used for NAT port (enter address which is assigned to the interface) '
    port_ip = STDIN.gets
    STDOUT.puts 'Begin of available port for NAT '
    port_start = STDIN.gets
    STDOUT.puts 'End of available port for NAT '
    port_stop = STDIN.gets
    STDOUT.puts 'Count of public IP used for NAT IP '
    ip_count = STDIN.gets
    ip_count = Integer(ip_count)
    STDOUT.puts 'Public IP used for NAT IP (one address per line, in format: x.x.x.x) '
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

    config_file.write(":ext_ip: #{ext_ip}")
    config_file.write(":port_ip: #{port_ip}")
    config_file.write(":port_start: #{port_start}")
    config_file.write(":port_stop: #{port_stop}")

    config_file.write(":ip:\n")
    ip.each { |i| config_file.write("    - #{i}") }

    config_file.close()
  end
end

task :clean => [:stop] do
  sh 'bundle exec ./clean.sh'
end

task :purge => [:clean] do
  sh 'bundle exec ./purge.sh'
end

task :run do
  sh 'bundle exec ./run.sh'
end

task :stop do
  sh 'bundle exec ./stop.sh'
end

task :rundevel do
  sh 'bundle exec ./devel-run.sh'
end
