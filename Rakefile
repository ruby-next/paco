# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Run Ruby Next nextify"
task :nextify do
  sh "bundle exec ruby-next nextify -V"
end

task default: :spec
