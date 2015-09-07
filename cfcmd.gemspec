# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cfcmd/version'

Gem::Specification.new do |spec|
  spec.name          = "cfcmd"
  spec.version       = CFcmd::VERSION
  spec.authors       = ["Adam Lassek"]
  spec.email         = ["alassek@lyconic.com"]

  spec.summary       = %q{A command-line interface for managing Rackspace CloudFiles based on the interface of s3cmd}
  spec.homepage      = "https://github.com/lyconic/cfcmd"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = "cfcmd"
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "fog"
  spec.add_dependency "toml"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"
end
