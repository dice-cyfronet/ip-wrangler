# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ip_wrangler/version'

Gem::Specification.new do |spec|
  spec.name          = 'ip-wrangler'
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

  spec.add_dependency 'sinatra', '~> 1.4'
  spec.add_dependency 'thin', '~> 1.6'

  spec.add_dependency 'sequel', '~> 4.19'
  spec.add_dependency 'sqlite3', '~> 1.3'

  spec.add_dependency 'json', '~> 1.8'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.4'
end
