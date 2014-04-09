require 'test/unit'
require 'json'

require './ipt_nat'
require './ipt_ip'

class IptNATTest < Test::Unit::TestCase

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

  def test_nat_port
    public_ip = [1, 0, 0, 1]
    public_port = 1024
    private_ip = [1, 0, 0, 2]
    private_port = 22
    protocol = 'tcp'

    public = Port.new(public_ip, public_port, protocol)
    private = Port.new(private_ip, private_port, protocol)

    nat_port = NATPort.new(public.ip, private.ip, public.port, private.port, protocol)

    assert(nat_port.protocol == protocol)
    assert(nat_port.public_ip == public_ip)
    assert(nat_port.public_port == public_port)
    assert(nat_port.private_ip == private_ip)
    assert(nat_port.private_port == private_port)

    assert(nat_port.to_json == "{\"public_ip\":[1,0,0,1],\"private_ip\":[1,0,0,2],\"public_port\":1024,\"private_port\":22,\"protocol\":\"tcp\"}")
  end

  def test_nat_ip
    public_ip = [1, 0, 0, 1]
    private_ip = [1, 0, 0, 2]

    public = IP.new(public_ip)
    private = IP.new(private_ip)

    nat_ip = NATIP.new(public.ip, private.ip)

    assert(nat_ip.public_ip == public_ip)
    assert(nat_ip.private_ip == private_ip)

    assert(nat_ip.to_json == "{\"public_ip\":[1,0,0,1],\"private_ip\":[1,0,0,2]}")
  end

  def test_nat_ip_2
    free_ips = range_ips([1, 0, 0, 2], [1, 0, 0, 4])

    nat = NAT.new([], free_ips, 'testipt.db')

    nat_ips = []
    (2..4).each do |i|
      nat_ip = nat.lock_ip(IP.new([127, 0, 0, 1]))
      assert(nat_ip != nil)
      assert(nat_ip.public_ip.ip == [1, 0, 0, i])
      nat_ips.push(nat_ip)
    end

    nat_ip = nat.lock_ip(IP.new([127, 0, 0, 1]))
    assert(nat_ip == nil)

    nat_ips.each do |ip|
      _ip = nat.free_ip(ip.private_ip, ip.public_ip)
      assert(_ip[0] == ip.public_ip, "#{_ip} != #{ip.public_ip}")
    end
  end

  def test_nat_port_2
    free_ports = range_ports(1024, 1028, [1, 0, 0, 1], 'tcp')

    nat = NAT.new(free_ports, [], 'testipt.db')

    nat_ports = []
    (1024..1028).each do |p|
      nat_port = nat.lock_ip_port(Port.new([127, 0, 0, 1], 22, 'tcp'))
      assert(nat_port != nil)
      assert(nat_port.public_ip == [1, 0, 0, 1])
      assert(nat_port.private_ip == [127, 0, 0, 1])
      assert(nat_port.public_port == p)
      assert(nat_port.private_port == 22)
      nat_ports.push(nat_port)
    end

    _port = nat.free_ip_port([127, 0, 0, 1], 22, 'tcp')
    i = 0
    (1024..1028).each do |port|
      assert(_port[i].ip == [1, 0, 0, 1])
      assert(_port[i].port == port)
      assert(_port[i].protocol == 'tcp')
      i += 1
    end
  end
end