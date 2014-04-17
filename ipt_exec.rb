$iptables_bin_path = '/sbin/iptables'

def execute_command(command)
  output = system "#{command}"
  puts "Execute: #{command} => output: #{output}, result: #{$?.exitstatus}"
  output
end

def execute_iptables_command(command)
  execute_command "#{$iptables_bin_path} #{command}"
end