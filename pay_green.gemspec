# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pay_green/version'

Gem::Specification.new do |spec|
  spec.name          = "pay_green"
  spec.version       = PayGreen::VERSION
  spec.authors       = ["mjet"]
  spec.email         = ["mjet@i-um.net"]

  spec.summary       = %q{PayGreen Integration For Ruby}
  spec.description   = %q{PayGreen Ruby SDK provides features as same as PayGreen Integration Moudle. This gem is that PHP Integration Moudle PayGreen Officially provided is translated for Ruby Users.}
  spec.homepage      = "https://github.com/mznet/pay_green"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
