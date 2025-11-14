# frozen_string_literal: true

require_relative "lib/rails_accessibility_testing/version"

Gem::Specification.new do |spec|
  spec.name          = "rails_accessibility_testing"
  spec.version       = RailsAccessibilityTesting::VERSION
  spec.authors       = ["Regan Maharjan"]
  spec.email         = ["imregan@umich.edu"]

  spec.summary       = "Zero-configuration accessibility testing for Rails system specs"
  spec.description   = "Automatically configures axe-core-capybara and provides helpers for accessibility testing in Rails applications. Includes comprehensive accessibility checks, detailed error messages, and automatic integration with RSpec."
  spec.homepage      = "https://github.com/rayraycodes/rails_accessibility_testing"
  spec.license       = "MIT"

  # Include all necessary files
  spec.files         = Dir[
    "lib/**/*.rb",
    "lib/**/*.rake",
    "lib/**/*.md",
    "exe/**/*",
    "README.md",
    "LICENSE",
    "CHANGELOG.md"
  ].reject { |f| f.match?(/\.yardoc|doc\//) }
  
  spec.require_paths = ["lib"]
  
  # Add executables
  spec.executables = ["rails_server_safe"]

  # Runtime dependencies
  spec.add_dependency "axe-core-capybara", "~> 4.0"
  spec.add_dependency "capybara", "~> 3.0"
  spec.add_dependency "rspec-rails", ">= 6.0"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "yard", "~> 0.9"
  
  # Metadata for RubyGems
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"
end

