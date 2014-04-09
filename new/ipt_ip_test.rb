require 'test/unit'

require './ipt_ip'

class IptIPTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.
  def teardown
    # Do nothing
  end

  def test_ip
    valid_ips = {'0.0.0.0' => [0, 0, 0, 0],
                 '8.8.8.8' => [8, 8, 8, 8],
                 '255.255.255.255' => [255, 255, 255, 255], }
    valid_ips.each do |ip|
      _ip = parse_ip(ip[0])
      assert(_ip == ip[1])
      assert(validate_ip(_ip))
      _ip = IP.new(_ip)
      assert(_ip.ip == ip[1])
      assert(validate_ip(_ip.ip))
    end

    invalid_ips = {'256.256.256.256' => [256, 256, 256, 256],
                   '256.0.0.0' => [256, 0, 0, 0],
                   '0.0.0.256' => [0, 0, 0, 256]}
    invalid_ips.each do |ip|
      _ip = parse_ip(ip[0])
      assert(_ip == ip[1])
      assert(!validate_ip(_ip))
      _ip = IP.new(_ip)
      assert(_ip.ip == ip[1])
      assert(!validate_ip(_ip.ip))
    end
  end

  def test_port
    valid_ports = [1, 1024, 65535]
    valid_ports.each do |port|
      _port = Port.new(nil, port, nil)
      assert(_port.port == port)
      assert(validate_port(_port.port))
    end

    invalid_ports = [0, 65536]
    invalid_ports.each do |port|
      _port = Port.new(nil, port, nil)
      assert(_port.port == port)
      assert(!validate_port(_port.port))
    end
  end

  def test_range_ip
    ips = range_ips([1, 0, 0, 1], [1, 0, 0, 16])
    i = 1
    ips.each do |ip|
      assert(ip.ip == [1, 0, 0, i])
      i += 1
    end
  end

  def test_range_port
    ips = range_ports(1024, 1032, [1, 0, 0, 1], 'tcp')
    p = 1024
    ips.each do |port|
      assert(port.ip == [1, 0, 0, 1])
      assert(port.port == p)
      assert(port.protocol == 'tcp')
      p += 1
    end
  end
end