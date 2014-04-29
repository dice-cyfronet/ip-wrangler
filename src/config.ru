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

$config = YAML.load_file('config.yml')

puts "Checking if #{$config[:db_name]} is existing..."

unless File.file?($config[:db_name])
  puts "Create #{$config[:db_name]}"
  FileUtils.touch($config[:db_name])
end

puts 'Checking database...'

db = Sequel.connect('sqlite://' + $config[:db_name])

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
end

unless db.table_exists? :nat_ips
  puts 'No nat_ips table. Creating it...'

  db.create_table? :nat_ips do
    primary_key :id
    String :public_ip
    String :private_ip
  end
end

db.disconnect

puts "Creating chain #{$config[:iptables_chain_name]}_PRE in nat table..."

execute_iptables_command Command.new_chain("#{$config[:iptables_chain_name]}_PRE", 'nat')

puts "Creating chain #{$config[:iptables_chain_name]}_POST in nat table..."

execute_iptables_command Command.new_chain("#{$config[:iptables_chain_name]}_POST", 'nat')

puts "Flush (if any rule exist) chain #{$config[:iptables_chain_name]}_PRE..."

execute_iptables_command Command.flush_chain("#{$config[:iptables_chain_name]}_PRE", 'nat')

puts "Flush (if any rule exist) chain #{$config[:iptables_chain_name]}_POST..."

execute_iptables_command Command.flush_chain("#{$config[:iptables_chain_name]}_POST", 'nat')

puts 'Appending rule to PREROUTING chain...'

execute_iptables_command Command.append_rule('PREROUTING', 'nat', [Parameter.jump("#{$config[:iptables_chain_name]}_PRE")])

puts 'Appending rule to POSTROUTING chain...'

execute_iptables_command Command.append_rule('POSTROUTING', 'nat', [Parameter.jump("#{$config[:iptables_chain_name]}_POST")])

Bundler.require

require File.dirname(__FILE__) + '/ipt_main.rb'

set :environment, ENV['RACK_ENV'].to_sym
set :app_file, 'ipt_main.rb'
set :raise_errors, true

use Rack::MethodOverride
disable :run, :reload

run Sinatra::Application

EventMachine.schedule do
  trap('INT') do
    puts 'Killing app...'

    puts 'Deleting rule from PREROUTING chain...'

    execute_iptables_command Command.delete_rule_spec('PREROUTING', [Parameter.jump("#{$config[:iptables_chain_name]}_PRE")], 'nat')

    puts 'Deleting rule from POSTROUTING chain...'

    execute_iptables_command Command.delete_rule_spec('POSTROUTING', [Parameter.jump("#{$config[:iptables_chain_name]}_POST")], 'nat')

    puts "Flush chain #{$config[:iptables_chain_name]}_PRE..."

    execute_iptables_command Command.flush_chain("#{$config[:iptables_chain_name]}_PRE", 'nat')

    puts "Flush chain #{$config[:iptables_chain_name]}_POST..."

    execute_iptables_command Command.flush_chain("#{$config[:iptables_chain_name]}_POST", 'nat')

    puts "Deleting chain #{$config[:iptables_chain_name]}_PRE from nat table..."

    execute_iptables_command Command.delete_chain("#{$config[:iptables_chain_name]}_PRE", 'nat')

    puts "Deleting chain #{$config[:iptables_chain_name]}_POST from nat table..."

    execute_iptables_command Command.delete_chain("#{$config[:iptables_chain_name]}_POST", 'nat')

    EventMachine.stop
  end
end