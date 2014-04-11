trap('SIGINT') do
  puts 'SIGINT'
end

require 'rubygems'
require 'bundler'

Bundler.require

require File.dirname(__FILE__) + '/ipt_main.rb'

set :environment, ENV['RACK_ENV'].to_sym
set :app_file, 'ipt_main.rb'
set :raise_errors, true

disable :run

log = File.new('log/ipt_wr_console.log', 'a')

STDOUT.reopen(log)
STDERR.reopen(log)

run Sinatra::Application