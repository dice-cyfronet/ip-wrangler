# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ip_wrangler/version'

Gem::Specification.new do |spec|
  spec.name          = 'ipwrangler'
  spec.version       = IpWrangler::VERSION
  spec.authors       = ['Paweł Suder']
  spec.email         = ['pawel@suder.info']
  spec.description   = %q{Iptables DNAT manager}
  spec.summary       = %q{Service is responsible for managing DNAT rules in iptables nat table}
  spec.homepage      = 'https://github.com/dice-cyfronet/ip-wrangler'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'sinatra'
  spec.add_dependency 'thin'

  spec.add_dependency 'sequel'
  spec.add_dependency 'sqlite3'

  spec.add_dependency 'json'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
end
