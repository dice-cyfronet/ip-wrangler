require 'getoptlong'
require 'yaml'
require 'sqlite3'
require File.dirname(__FILE__) + '/ipt_wr_tools'

$config = YAML.load_file('config.yml')
$ip = nil
$tpr = nil
$upr = nil

opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--ip', '-i', GetoptLong::REQUIRED_ARGUMENT],
    ['--tcp-port', '-t', GetoptLong::REQUIRED_ARGUMENT],
    ['--udp-port', '-u', GetoptLong::REQUIRED_ARGUMENT]
)

def add_port_r(p1,p2)
  raise 'Wrong ports order' if p1 > p2

  (p1..p2).to_a.each {|p| add_port_s p}
end

def add_port_s(p)
  raise 'Illegal port' if p < 1 or p > 65535

  $db.execute('INSERT INTO NatPorts VALUES ( "149.156.10.132", ?)', p)
end

# @param [String] pr
def add_port(pr)
  p_range = pr.split ':'
  case p_range.length
    when 1
      add_port_s p_range[0].to_i
    when 2
      add_port_r p_range[0].to_i,p_range[1].to_i
    else
      raise '[add_ip] Syntax error'
  end
end

def usage
  puts 'Usage: ipt_wr_manage [OPTIONS] <cmd>'
  exit 1
end

def init_database
  puts 'Initializing database...'
  $db = SQLite3::Database.new('ipt_wr.db')
  $db.execute('CREATE TABLE IF NOT EXISTS NatRules (pubIp TEXT NOT NULL, privIp TEXT NOT NULL, pubPort INT NOT NULL, privPort INT NOT NULL, proto TEXT NOT NULL, ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP, Desc TEXT)')
  $db.execute('CREATE TABLE IF NOT EXISTS NatPorts (pubIp TEXT NOT NULL, pubPort INT NOT NULL, privIp TEXT DEFAULT NULL, privPort INT DEFAULT NULL, proto TEXT DEFAULT NULL, created TIMESTAMP DEFAULT CURRENT_TIMESTAMP)')
end

def p_decode(proto, ps)

  r = ps.split ':'
  p = Array.new 2

  case r.length
    when 1
      p[0] = r[0].to_i
      p[1] = p[0]
    when 2
      p[0] = r[0].to_i
      p[1] = r[1].to_i
    else
      raise '[add_ip] Syntax error'
  end

  IPTWr::PortRange.new proto, p[0], p[1]
end

begin
opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
ipt_wr_manage [OPTIONS] <cmd>
-h, --help:
  Help
-i, --ip
  Public IP address
-t, --tcp-port x[:y]
  TCP port, or port range
-u, --udp-port x[:y]
  UDP port, or port ramge
Commands:
initdb - create database and fill initial data
list - list all ports
add - add port / all ports in range
del - remove port / all ports in range
      EOF
    when '--ip'
      $ip = IPTWr::IPAddress.new arg
    when '--tcp-port'
      $tpr = p_decode IPTWr::PortRange::PROTO_TCP, arg
    when '--udp-port'
      $upr = p_decode IPTWr::PortRange::PROTO_UDP, arg
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
    init_database
  else
    puts 'Unknown command'
    usage
    exit(2)
end