# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'double_double/version'

Gem::Specification.new do |gem|
  gem.name          = 'double_double'
  gem.version       = DoubleDouble::VERSION
  gem.authors       = ['Mike Herrera']
  gem.email         = ['git@devoplabs.com']
  gem.description   = %q{A double-entry accural accounting system}
  gem.summary       = %q{A double-entry accural accounting system. All currency amounts are stored using the Money gem.}
  gem.homepage      = 'https://github.com/crftr/double_double'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features|account_types)/})
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 1.9.2'

  gem.add_dependency 'money', '~> 5.1'
  gem.add_dependency 'activerecord',  '~> 4.2'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'rspec', '~> 2.12'
  gem.add_development_dependency 'factory_girl'
  gem.add_development_dependency 'database_cleaner'
  gem.add_development_dependency 'pry'
end
