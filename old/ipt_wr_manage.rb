require 'getoptlong'
require 'yaml'
require 'sqlite3'
require File.dirname(__FILE__) + '/ipt_wr_tools'

#$config = YAML.load_file('config.yml')
$db_name = nil
$ip = nil
$proto = nil
$p1 = nil
$p2 = nil


opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--db', '-d', GetoptLong::REQUIRED_ARGUMENT],
    ['--ip', '-i', GetoptLong::REQUIRED_ARGUMENT],
    ['--tcp', '-t', GetoptLong::NO_ARGUMENT],
    ['--udp', '-u', GetoptLong::NO_ARGUMENT],
    ['--port', '-p', GetoptLong::REQUIRED_ARGUMENT],
    ['--port-min', '-m', GetoptLong::REQUIRED_ARGUMENT],
    ['--port-max', '-x', GetoptLong::REQUIRED_ARGUMENT]
)

def add_port_r(p1, p2)
  raise 'Wrong ports order' if p1 > p2

  (p1..p2).to_a.each { |p| add_port_s p }
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
      add_port_r p_range[0].to_i, p_range[1].to_i
    else
      raise '[add_ip] Syntax error'
  end
end

def usage
  puts 'Usage: ipt_wr_manage [OPTIONS] <cmd>'
  exit 1
end

def init_database(db_name)
  puts 'Initializing database...'
  db = IptWr::Database.new db_name
  db.create

  #$db = SQLite3::Database.new('ipt_wr.db')
  #$db.execute('CREATE TABLE IF NOT EXISTS NatRules (pubIp TEXT NOT NULL, privIp TEXT NOT NULL, pubPort INT NOT NULL, privPort INT NOT NULL, proto TEXT NOT NULL, ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP, Desc TEXT)')
  #$db.execute('CREATE TABLE IF NOT EXISTS NatPorts (pubIp TEXT NOT NULL, pubPort INT NOT NULL, privIp TEXT DEFAULT NULL, privPort INT DEFAULT NULL, proto TEXT DEFAULT NULL, created TIMESTAMP DEFAULT CURRENT_TIMESTAMP)')
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

  IptWr::PortRange.new proto, p[0], p[1]
end

def add

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
-i, --ip
  Public IP address
-t, --tcp
  TCP port range
-u, --udp
  UDP port range
-p, --port
  single port (excludes -m and -x)
-m, --port-min
  lower port (excludes -p)
-x, --port-max
  upper port (excludes -p)
Commands:
initdb - create database and fill initial data
list - list all ports
add - add port / all ports in range
del - remove port / all ports in range
        EOF
      when '--db'
        $db_name = arg
      when '--ip'
        $ip = arg
      when '--tcp'
        unless $proto.nil?
          puts 'Conflict between --tcp and --udp'
          exit 3
        end
        $proto = IptWr::Protocol::PROTO_TCP
      when '--udp'
        unless $proto.nil?
          puts 'Conflict between --tcp and --udp'
          exit 4
        end
        $proto = IptWr::Protocol::PROTO_UDP
      when '--port'
        unless $p1.nil?
          puts 'Conflict: --port, --port-min, --port-max'
          exit 5
        end
        $p1 = arg.to_i
        unless $p2.nil?
          puts 'Conflict: --port, --port-min, --port-max'
          exit 6
        end
        $p2 = arg.to_i
      when '--port-min'
        unless $p1.nil?
          puts 'Conflict: --port, --port-min, --port-max'
          exit 7
        end
        $p1 = arg.to_i
      when '--port-max'
        unless $p2.nil?
          puts 'Conflict: --port, --port-min, --port-max'
          exit 8
        end
        $p2 = arg.to_i
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
  when 'add'
    if $db_name.nil?
      puts 'Database name not set'
      usage
      exit 9
    end
    if $ip.nil?
      puts 'IP not defined'
    end
    if $p1.nil? or $p2.nil?
      puts 'Ports not defined'
      exit 11
    end
    if $proto.nil?
      puts 'Protocol not defined'
      exit 12
    end
    nps = IptWr::NatPorts.new
    nps.add_range $ip, $proto, $p1, $p2
    nps.db_save IptWr::Database.new $db_name
  else
    puts 'Unknown command'
    usage
    exit(2)
end