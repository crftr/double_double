require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc 'run specs'
task :spec do
  sh('bundle', 'exec', 'rspec')
end

task default: :spec