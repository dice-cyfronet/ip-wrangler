require 'getoptlong'

opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--initdb', '-i', GetoptLong::NO_ARGUMENT]
)

def usage
  puts 'Usage: ipt_wr_manage [OPTIONS]'
  exit 1
end

def init_database
  $db = SQLite3::Database.new('ipt_wr.db')
  $db.execute('CREATE TABLE IF NOT EXISTS NatRules (pubIp TEXT NOT NULL, privIp TEXT NOT NULL, pubPort INT NOT NULL, privPort INT NOT NULL, proto TEXT NOT NULL, ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP, Desc TEXT)')
  $db.execute('CREATE TABLE IF NOT EXISTS NatPorts (id INT NOT NULL UNIQUE, pubIp TEXT NOT NULL, pubPort INT NOT NULL, privIp TEXT DEFAULT NULL, privPort INT DEFAULT NULL, proto TEXT DEFAULT NULL, created TIMESTAMP DEFAULT CURRENT_TIMESTAMP)')
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