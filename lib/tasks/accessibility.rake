# frozen_string_literal: true

namespace :a11y do
  desc "Run all accessibility tests"
  task :test do
    sh "bundle exec rspec spec/system/ --tag accessibility"
  end

  desc "Run accessibility tests in watch mode"
  task :watch do
    sh "bundle exec rspec spec/system/ --tag accessibility --watch"
  end

  desc "Run all system tests (includes accessibility)"
  task :system do
    sh "bundle exec rspec spec/system/"
  end

  desc "Run accessibility tests for a specific file"
  task :file, [:file] do |t, args|
    file = args[:file] || "spec/system/rte_loaded_spec.rb"
    sh "bundle exec rspec #{file}"
  end
end

desc "Run accessibility tests (alias for a11y:test)"
task a11y: "a11y:test"

