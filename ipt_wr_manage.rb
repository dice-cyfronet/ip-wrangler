require 'getoptlong'
require 'yaml'
require 'sqlite3'
require File.dirname(__FILE__) + '/ipt_wr_tools'

$db_name = nil

opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--db', '-d', GetoptLong::REQUIRED_ARGUMENT]
)


def usage
  puts 'Usage: ipt_wr_manage [OPTIONS] <cmd>'
  exit 1
end

def init_database(db_name)
  puts 'Initializing database...'
  db = IptWr::Database.new db_name
  db.create
end

begin
opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
ipt_wr_manage [OPTIONS] <cmd>
-h, --help:
  Help
-d, --db
  Database name
Commands:
initdb - create database and fill initial data
      EOF
    when '--db'
      $db_name = arg
    else
      # Should not happen but...
      raise Error.new
  end
end
rescue GetoptLong::Error
  usage
end

if ARGV.length != 1
  puts 'Command missing' if ARGV.length == 0
  usage
  exit(1)
end

cmd = ARGV.shift

case cmd
  when 'initdb'
    if $db_name.nil?
      puts 'Database name not set'
      usage
      exit 9
    end
    init_database $db_name
  else
    puts 'Unknown command'
    usage
    exit(2)
end