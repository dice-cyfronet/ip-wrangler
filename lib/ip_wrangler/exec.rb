module IpWrangler
  module Exec
    $iptables_bin_path = '/usr/bin/sudo /sbin/iptables'
    $logger = Logger.new(STDOUT)

    extend self

    def execute_command(command)
      output = `#{command}`
      $logger.info("Execute: #{command} => output: #{output}, result: #{$?.exitstatus}")
      output
    end

    def execute_iptables_command(command)
      execute_command("#{$iptables_bin_path} #{command}")
    end
  end
end
