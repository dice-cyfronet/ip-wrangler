$iptables_bin_path = '/sbin/iptables'
$awk_bin_path = '/usr/bin/awk'
$tail_bin_path = '/usr/bin/tail'
$grep_bin_path = '/bin/grep'

class Iptables

  def initialize(chain_name, iptables_bin_path, logger)
    @chain_name = chain_name
    @logger = logger
    @iptables_bin_path = iptables_bin_path
  end

  def rule_nat_port(public_ip, public_port, private_ip, private_port, protocol)
    [Parameter.destination(public_ip),
     Parameter.protocol(protocol),
     Parameter.destination_port(public_port),
     Parameter.jump('DNAT'),
     Parameter.to_destination("#{private_ip}:#{private_port}")]
  end

  def rule_nat_ip(public_ip, private_ip)
    rule_dnat = [Parameter.destination(public_ip),
                 Parameter.jump('DNAT'),
                 Parameter.to_destination(private_ip)]
    rule_snat = [Parameter.source(private_ip),
                 Parameter.jump('SNAT'),
                 Parameter.to_destination(public_ip)]

    return rule_dnat, rule_snat
  end

  def append_nat_port(public_ip, public_port, private_ip, private_port, protocol)
    rule = rule_nat_port public_ip, public_port, private_ip, private_port, protocol

    command = Command.append_rule @chain_name, 'nat', rule

    execute command
  end

  def append_nat_ip(public_ip, private_ip)
    rule_dnat, rule_snat = rule_nat_ip public_ip, private_ip

    command_dnat = Command.append_rule @chain_name, 'nat', rule_dnat
    command_snat = Command.append_rule @chain_name, 'nat', rule_snat

    execute command_dnat, command_snat
  end

  def delete_nat_port(public_ip, public_port, private_ip, private_port, protocol)
    rule = rule_nat_port public_ip, public_port, private_ip, private_port, protocol

    command = Command.delete_rule_spec @chain_name, rule, 'nat'

    execute command
  end

  def delete_nat_ip(public_ip, private_ip)
    rule_dnat, rule_snat = rule_nat_ip public_ip, private_ip

    command_dnat = Command.delete_rule_spec @chain_name, rule_dnat, 'nat'
    command_snat = Command.delete_rule_spec @chain_name, rule_snat, 'nat'

    execute command_dnat, command_snat
  end

  def exists_nat_port?(public_ip, public_port, protocol, private_ip, private_port)
    command = "#{$iptables_bin_path} -t nat -L -n -v #{@chain_name} | #{$awk_bin_path} '{print $9, $10, $11, $12}' | #{$grep_bin_path} -i '^#{public_ip} #{protocol} dpt:#{public_port} to:#{private_ip}:#{private_port}$'"
    output = `#{command}`.empty?
    @logger.info "#{command} =>\n\toutput: #{output}\n\texitstatus: #{$?.exitstatus}"
  end

  def exists_nat_ip?(public_ip, private_ip)
    command = "#{$iptables_bin_path} -t nat -L -n -v #{@chain_name} | #{$awk_bin_path} '{print $9, $10}' | #{$grep_bin_path} -i '^#{public_ip}' to:#{private_ip}"
    output = `#{command}`.empty?
    @logger.info "#{command} =>\n\toutput: #{output}\n\texitstatus: #{$?.exitstatus}"
  end

  def execute(*commands)
    commands.each do |command|
      output = system "#{@iptables_bin_path} #{command}"
      @logger.info "#{@iptables_bin_path} #{command} =>\n\toutput: #{output}\n\texitstatus: #{$?.exitstatus}"
    end
  end

end

class Command

  @@commands = {
      append_rule: '--append',
      insert_rule: '--insert',
      replace_rule: '--replace',
      check_rule: '--check',
      delete_rule: '--delete',
      new_chain: '--new-chain',
      rename_chain: '--rename-chain',
      policy_chain: '--policy',
      zero_chain: '--zero',
      flush_chain: '--flush',
      delete_chain: '--delete-chain',
  }

  def self.parameters_to_s(parameters)
    __parameters = ''
    parameters.each { |parameter| __parameters = "#{__parameters} #{parameter} " }
    "#{__parameters}".gsub(/\s+/, ' ')
  end

  def self.append_rule(chain, table, parameters)
    "-t #{table} #{@@commands[:append_rule]} #{chain} #{parameters_to_s(parameters)}"
  end

  def self.insert_rule(chain, num, table, parameters)
    "-t #{table} #{@@commands[:insert_rule]} #{chain} #{num} #{parameters_to_s(parameters)}"
  end

  def self.replace_rule(chain, num, table, parameters)
    "-t #{table} #{@@commands[:replace_rule]} #{chain} #{num} #{parameters_to_s(parameters)}"
  end

  def self.check_rule(chain, table, parameters)
    "-t #{table} #{@@commands[:check_rule]} #{chain} #{parameters_to_s(parameters)}"
  end

  def self.delete_rule(chain, num, table)
    "-t #{table} #{@@commands[:delete_rule]} #{chain} #{num}"
  end

  def self.delete_rule_spec(chain, parameters, table)
    "-t #{table} #{@@commands[:delete_rule]} #{chain} #{parameters_to_s(parameters)}"
  end

  def self.new_chain(chain, table)
    "-t #{table} #{@@commands[:new_chain]} #{chain}"
  end

  def self.rename_chain(old_chain, new_chain, table)
    "-t #{table} #{@@commands[:rename_chain]} #{old_chain} #{new_chain}"
  end

  def self.policy_chain(chain, target, table)
    "-t #{table} #{@@commands[:policy_chain]} #{chain} #{target}"
  end

  def self.zero_chain(chain, num, table)
    "-t #{table} #{@@commands[:zero_chain]} #{chain} #{num}"
  end

  def self.flush_chain(chain, table)
    "-t #{table} #{@@commands[:flush_chain]} #{chain}"
  end

  def self.delete_chain(chain, table)
    "-t #{table} #{@@commands[:delete_chain]} #{chain}"
  end

end

class Parameter

  @@parameters = {
      protocol: '--protocol',
      source: '--source',
      destination: '--destination',
      source_port: '--source-port',
      destination_port: '--destination-port',
      in_interface: '--in-interface',
      out_interface: '--out-interface',
      to_destination: '--to-destination',
      jump: '--jump',
  }

  def initialize(name, value=nil)
    @name, @value = name, value
  end

  def to_s
    "#{@name} #{@value}"
  end

  def self.protocol(protocol)
    new(@@parameters[:protocol], protocol)
  end

  def self.source(source)
    new(@@parameters[:source], source)
  end

  def self.destination(destination)
    new(@@parameters[:destination], destination)
  end

  def self.source_port(source_port)
    new(@@parameters[:source_port], source_port)
  end

  def self.destination_port(destination_port)
    new(@@parameters[:destination_port], destination_port)
  end

  def self.in_interface(in_interface)
    new(@@parameters[:in_interface], in_interface)
  end

  def self.out_interface(out_interface)
    new(@@parameters[:out_interface], out_interface)
  end

  def self.to_destination(destination)
    new(@@parameters[:to_destination], destination)
  end

  def self.jump(target)
    new(@@parameters[:jump], target)
  end

end