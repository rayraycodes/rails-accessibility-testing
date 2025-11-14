# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "yard"

RSpec::Core::RakeTask.new(:spec)

desc "Run all tests"
task default: :spec

desc "Build the gem"
task build: :gemspec do
  system "gem build rails_accessibility_testing.gemspec"
end

desc "Generate YARD documentation"
YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb"]
  t.options = ["--no-private"]
end

desc "Clean build artifacts"
task :clean do
  rm_f "*.gem"
  rm_rf "pkg"
  rm_rf ".yardoc"
  rm_rf "doc"
end

desc "Release the gem"
task :release, [:version] => [:clean, :build, :spec] do |_t, args|
  version = args[:version] || ENV["VERSION"]
  raise "Version required" unless version

  sh "git tag -a v#{version} -m 'Release v#{version}'"
  sh "git push origin v#{version}"
  sh "gem push rails_accessibility_testing-#{version}.gem"
end
