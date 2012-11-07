require './ipt_wr'

set :environment, ENV['RACK_ENV'].to_sym
set :app_file,     'ipt_wr.rb'
disable :run
set :raise_errors, true

log = File.new("logs/ipt_wr_outerr.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)

run Sinatra::Application
