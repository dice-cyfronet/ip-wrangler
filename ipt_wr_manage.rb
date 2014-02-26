require 'getoptlong'
require 'yaml'
require 'sqlite3'

$config = YAML.load_file('config.yml')

opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--initdb', '-i', GetoptLong::NO_ARGUMENT],
    ['--add-port', '-a', GetoptLong::REQUIRED_ARGUMENT]
)

def add_port_r(p1,p2)
  raise 'Wrong ports order' if p1 > p2

  (p1..p2).to_a.each {|p| add_port_s p}
end

def add_port_s(p)
  raise 'Illegal port' if p < 1 or p > 65535

  $db.execute('INSERT INTO NatPorts VALUES ( "149.156.10.132", ?)', p)
end

# @param [String] ip
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
  puts 'Usage: ipt_wr_manage [OPTIONS]'
  exit 1
end

def init_database
  puts 'Initializing database...'
  $db = SQLite3::Database.new('ipt_wr.db')
  $db.execute('CREATE TABLE IF NOT EXISTS NatRules (pubIp TEXT NOT NULL, privIp TEXT NOT NULL, pubPort INT NOT NULL, privPort INT NOT NULL, proto TEXT NOT NULL, ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP, Desc TEXT)')
  $db.execute('CREATE TABLE IF NOT EXISTS NatPorts (pubIp TEXT NOT NULL, pubPort INT NOT NULL, privIp TEXT DEFAULT NULL, privPort INT DEFAULT NULL, proto TEXT DEFAULT NULL, created TIMESTAMP DEFAULT CURRENT_TIMESTAMP)')
end

op = 0

begin
opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
ipt_wr_manage [OPTIONS]
-h, --help:
  Help
      EOF
    when '--initdb'
      init_database
    else
      # Should not happen but...
      raise Error.new
  end
  op = op + 1
end
rescue GetoptLong::Error
  usage
end


usage unless op > 0