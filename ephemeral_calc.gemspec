# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ephemeral_calc/version'

Gem::Specification.new do |spec|
  spec.name          = "ephemeral_calc"
  spec.version       = EphemeralCalc::VERSION

  spec.authors       = ["Radius Networks"]
  spec.email         = ["support@radiusnetworks.com"]

  spec.summary       = %q{Tools to calculate Eddystone ephemeral identifiers}
  spec.description   = %q{Tools to calculate Eddystone ephemeral identifiers}
  spec.homepage      = "https://github.com/RadiusNetworks/ephemeral_calc"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.extensions    = %w[ext/curve25519/extconf.rb]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.0'

  spec.add_runtime_dependency "proximity_beacon", "~> 0.1.3"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rake-compiler"
end
