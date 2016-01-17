require "bundler/gem_tasks"

require 'rake/testtask'

task :default => :test

Rake::TestTask.new(:test) do |task|
  task.libs << "lib/api"
  task.libs << "test"
  task.test_files = FileList['test/**/*test.rb']
end
