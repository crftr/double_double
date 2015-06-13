# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'double_double/version'

Gem::Specification.new do |gem|
  gem.name          = 'double_double'
  gem.version       = DoubleDouble::VERSION
  gem.authors       = ['Mike Herrera']
  gem.email         = 'michael.herrera@gmail.com'
  gem.description   = %q{A double-entry accural accounting system}
  gem.summary       = %q{A double-entry accural accounting system. All currency amounts are stored using the Money gem.}
  gem.homepage      = 'https://github.com/crftr/double_double'
  gem.licenses      = ['MIT']

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features|account_types)/})
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 1.9.3'

  gem.add_dependency 'money'
  gem.add_dependency 'monetize'
  gem.add_dependency 'activerecord'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'factory_girl'
  gem.add_development_dependency 'database_cleaner'
  gem.add_development_dependency 'generator_spec'
end
