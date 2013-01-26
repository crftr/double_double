require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc 'run specs'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["--color", "--format progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

task default: :spec