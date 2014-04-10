$tables = {
    filter: 'filter',
    nat: 'nat',
    mangle: 'mangle',
    raw: 'raw',
    security: 'security'
}

class Base

  def initialize(chains=[])
    @chains = chains
  end

  def add_chain(chain)
    @chains << chain
    self
  end

  def to_s
    chains = ''
    @chains.each { |chain| chains = "#{chains}\n#{chain}" }
    "#{chains}"
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

  def self.append_rule(chain, table, parameters)
    "-t #{table} #{@@commands[:append_rule]} #{chain} #{parameters}"
  end

  def self.insert_rule(chain, num, table, parameters)
    "-t #{table} #{@@commands[:insert_rule]} #{chain} #{num} #{parameters}"
  end

  def self.replace_rule(chain, num, table, parameters)
    "-t #{table} #{@@commands[:replace_rule]} #{chain} #{num} #{parameters}"
  end

  def self.check_rule(chain, table, parameters)
    "-t #{table} #{@@commands[:check_rule]} #{chain} #{parameters}"
  end

  def self.delete_rule(chain, num, table)
    "-t #{table} #{@@commands[:delete_rule]} #{chain} #{num}"
  end

  def self.delete_rule_spec(chain, spec, table)
    "-t #{table} #{@@commands[:delete_rule]} #{chain} #{spec}"
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

class Chain

  def initialize(rules=[])
    @rules = rules
  end

  def add_rule(rule)
    @rules << rule
    self
  end

  def to_s
    rules = ''
    @rules.each { |rule| rules = "#{rules}\n#{rule}" }
    "#{rules}".gsub(/\s+/, ' ')
  end

end

class Rule

  def initialize(parameters=[])
    @parameters = parameters
  end

  def add_parameter(parameter)
    @parameters << parameter
    self
  end

  def to_s
    parameters = ''
    @parameters.each { |parameter| parameters = "#{parameters} #{parameter} " }
    "#{parameters}".gsub(/\s+/, ' ')
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
      to: '--to-destination',
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

  def self.jump(target)
    new(@@parameters[:jump], target)
  end

  def self.to(destination)
    new(@@parameters[:to], destination)
  end

end

def rule_nat_ip_port(public_ip, public_port, private_ip, private_port, protocol)
  Rule.new([Parameter.destination("#{public_ip}"),
            Parameter.protocol(protocol), Parameter.destination_port(public_port),
            Parameter.jump('DNAT'), Parameter.to("#{private_ip}:#{private_port}")])
end

def rule_nat_ip(public_ip, private_ip)
  rule_dnat = Rule.new([Parameter.destination("#{public_ip}"),
                        Parameter.jump('DNAT'), Parameter.to("#{private_ip}")])
  rule_snat = Rule.new([Parameter.source("#{private_ip}"),
                        Parameter.jump('SNAT'), Parameter.to("#{public_ip}")])
  return rule_dnat, rule_snat
end

def append_nat_ip_port(public_ip, public_port, private_ip, private_port, protocol)
  rule = rule_nat_ip_port(public_ip, public_port, private_ip, private_port, protocol)
  Command.append_rule('PREROUTING', 'nat', rule)
end

def append_nat_ip(public_ip, private_ip)
  rule_dnat, rule_snat = rule_nat_ip(public_ip, private_ip)

  dnat = Command.append_rule('PREROUTING', 'nat', rule_dnat)
  snat = Command.append_rule('POSTROUTING', 'nat', rule_snat)

  return dnat, snat
end

def delete_nat_ip_port(public_ip, public_port, private_ip, private_port, protocol)
  rule = rule_nat_ip_port(public_ip, public_port, private_ip, private_port, protocol)
  Command.delete_rule_spec('PREROUTING', rule, 'nat')
end

def delete_nat_ip(public_ip, private_ip)
  rule_dnat, rule_snat = rule_nat_ip(public_ip, private_ip)

  dnat = Command.delete_rule_spec('PREROUTING', rule_dnat, 'nat')
  snat = Command.delete_rule_spec('POSTROUTING', rule_snat, 'nat')

  return dnat, snat
end