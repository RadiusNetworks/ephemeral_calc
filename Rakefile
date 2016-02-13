require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rake/extensiontask"

Rake::ExtensionTask.new "curve25519" do |ext|
  ext.lib_dir = "lib/ephemeral_calc"
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
