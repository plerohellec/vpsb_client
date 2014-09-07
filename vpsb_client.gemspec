# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vpsb_client/version'

Gem::Specification.new do |spec|
  spec.name          = "vpsb_client"
  spec.version       = VpsbClient::VERSION
  spec.authors       = ["Philippe Le Rohellec"]
  spec.email         = ["philippe@lerohellec.com"]
  spec.summary       = "Client gem for vpsbenchmarks.com"
  spec.description   = "It allows creating and upddating trials."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'curb'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "byebug"
end
