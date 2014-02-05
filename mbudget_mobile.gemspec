# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mbudget_mobile/version'

Gem::Specification.new do |spec|
  spec.name          = "mbudget_mobile"
  spec.version       = MbudgetMobile::VERSION
  spec.authors       = ["Jonathan Müller"]
  spec.email         = ["j.mueller@apoveda.ch"]
  spec.summary       = %q{A ruby gem to make access to the Swiss Migros Budget Mobile provider customer website easier}
  spec.description   = %q{At the moment, only login and reading the current balance are supported.}
  spec.homepage      = "http://github.com/jo-m/mbudget_mobile/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
