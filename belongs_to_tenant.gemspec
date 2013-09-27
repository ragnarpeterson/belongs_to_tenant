# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'belongs_to_tenant/version'

Gem::Specification.new do |spec|
  spec.name          = "belongs_to_tenant"
  spec.version       = BelongsToTenant::VERSION
  spec.authors       = ["Jason Kriss"]
  spec.email         = ["jasonkriss@gmail.com"]
  spec.description   = %q{Bare bones multi-tenancy}
  spec.summary       = %q{Bare bones multi-tenancy}
  spec.homepage      = "https://github.com/jasonkriss/belongs_to_tenant"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails', '>= 3.1'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "shoulda-matchers"
  spec.add_development_dependency "sqlite3"
end
