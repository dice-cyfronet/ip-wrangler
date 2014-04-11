require 'thin'
require 'sinatra'
require 'eventmachine'

require 'rubygems'
require 'bundler'

require 'fileutils'

Bundler.require

require File.dirname(__FILE__) + '/ipt_main.rb'

set :environment, ENV['RACK_ENV'].to_sym
set :app_file, 'ipt_main.rb'
set :raise_errors, true

disable :run

log = File.new('log/ipt_wr_console.log', 'a')

STDOUT.reopen(log)
STDERR.reopen(log)

puts 'Checking if config.yml is existing...'

unless File.file?('config.yml')
  puts 'No config.yml file found. Exiting.'
  exit(1)
end

$config = YAML.load_file('config.yml')

unless "Checking if #{$config[:db]} is existing..."
  FileUtils.touch($config[:db])
end

puts 'Checking database...'

db = Sequel.connect('sqlite://' + $config[:db])

db.create_table? :nat_ports do
  primary_key :id
  String :public_ip
  Int :public_port
  String :private_ip
  Int :private_port
  String :protocol
end

db.create_table? :nat_ips do
  primary_key :id
  String :public_ip
  String :private_ip
end

db.disconnect

command = Command.new_chain($config[:iptables_chain], 'nat')
`#{$config[:iptables_path]} #{command}`

command = Command.append_rule('PREROUTING', 'nat', Rule.new([Parameter.jump($config[:iptables_chain])]))
`#{$config[:iptables_path]} #{command}`

run Sinatra::Application

EventMachine.schedule do
  trap('INT') do
    puts 'Killing app...'

    command = Command.delete_rule_spec('PREROUTING', 'nat', Rule.new([Parameter.jump($config[:iptables_chain])]))
    `#{$config[:iptables_path]} #{command}`

    command = Command.delete_chain($config[:iptables_chain], 'nat')
    `#{$config[:iptables_path]} #{command}`

    EventMachine.stop
  end
end