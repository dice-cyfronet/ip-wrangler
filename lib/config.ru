require 'bundler'
require 'eventmachine'
require 'fileutils'
require 'json'
require 'logger'
require 'rubygems'
require 'sequel'
require 'sinatra'
require 'thin'
require 'yaml'

require './ipt_db'
require './ipt_ip'
require './ipt_iptables'
require './ipt_nat'
require './ipt_exec'

unless ENV.has_key?('__NO_LOG')
  console_logger = File.new('log/ipt_wr_console.log', 'w')

  STDOUT.reopen(console_logger)
  STDERR.reopen(console_logger)
end

puts 'Checking if config.yml is existing...'

unless File.file?('config.yml')
  puts 'No config.yml file found. Exiting.'
  exit(1)
end

config = YAML.load_file('config.yml')

puts "Checking if #{config[:db_name]} is existing..."

unless File.file?(config[:db_name])
  puts "Create #{config[:db_name]}"
  FileUtils.touch(config[:db_name])
end

puts 'Checking database...'

db = Sequel.connect('sqlite://' + config[:db_name])

unless db.table_exists? :nat_ports
  puts 'No nat_ports table. Creating it...'

  db.create_table? :nat_ports do
    primary_key :id
    String :public_ip
    Int :public_port
    String :private_ip
    Int :private_port
    String :protocol
  end

  db.add_index :nat_ports, [:public_ip, :public_port]

  %w(tcp udp).each do |protocol|
    ports = (config[:port_start]..config[:port_stop]).map { |port| [config[:port_ip], port, nil, nil, protocol] }.to_a
    db[:nat_ports].import([:public_ip, :public_port, :private_ip, :private_port, :protocol], ports)
  end

end

unless db.table_exists? :nat_ips
  puts 'No nat_ips table. Creating it...'

  db.create_table? :nat_ips do
    primary_key :id
    String :public_ip
    String :private_ip
  end

  db.add_index :nat_ips, :public_ip

  if config[:ip] != nil
    config[:ip].each do |public_ip|
      db[:nat_ips].insert(:public_ip => public_ip, :private_ip => nil)
      puts "Add ip:#{public_ip}"
    end
  end
end

db.disconnect

puts "Creating chain #{config[:iptables_chain_name]}_PRE in nat table..."
execute_iptables_command Command.new_chain("#{config[:iptables_chain_name]}_PRE", 'nat')

puts "Creating chain #{config[:iptables_chain_name]}_POST in nat table..."
execute_iptables_command Command.new_chain("#{config[:iptables_chain_name]}_POST", 'nat')

puts 'Appending rule, if not exists, to PREROUTING chain...'
execute_iptables_command Command.check_rule('PREROUTING', 'nat', [Parameter.jump("#{config[:iptables_chain_name]}_PRE")])
if $?.exitstatus == 1
  execute_iptables_command Command.append_rule('PREROUTING', 'nat', [Parameter.jump("#{config[:iptables_chain_name]}_PRE")])
end

puts 'Appending rule, if not exists, to POSTROUTING chain...'
execute_iptables_command Command.check_rule('POSTROUTING', 'nat', [Parameter.jump("#{config[:iptables_chain_name]}_POST")])
if $?.exitstatus == 1
  execute_iptables_command Command.append_rule('POSTROUTING', 'nat', [Parameter.jump("#{config[:iptables_chain_name]}_POST")])
end

Bundler.require

require File.dirname(__FILE__) + '/ipt_main.rb'

set :environment, ENV['RACK_ENV'].to_sym
set :app_file, 'ipt_main.rb'
set :raise_errors, true

use Rack::MethodOverride
disable :run, :reload

run Sinatra::Application