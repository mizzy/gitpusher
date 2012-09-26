require "bundler/gem_tasks"
require "rspec/core/rake_task"

task :default => :spec

RSpec::Core::RakeTask.new do |task|
  task.rspec_opts = ['--format=documentation', '--colour']
end
