# frozen_string_literal: true

require_relative "lib/rails_accessibility_testing/version"

Gem::Specification.new do |spec|
  spec.name          = "rails_accessibility_testing"
  spec.version       = RailsAccessibilityTesting::VERSION
  spec.authors       = ["Regan Maharjan"]
  spec.email         = ["imregan@umich.edu"]

  spec.summary       = "The RSpec + RuboCop of accessibility for Rails. Catch WCAG violations before they reach production."
  spec.description   = "Comprehensive, opinionated but configurable accessibility testing gem for Rails. Integrates seamlessly into your test suite with RSpec and Minitest support. Includes CLI tool, Rails generator, YAML configuration, and 11+ WCAG 2.1 AA aligned checks with actionable error messages."
  spec.homepage      = "https://github.com/rayraycodes/rails_accessibility_testing"
  spec.license       = "MIT"

  # Include all necessary files
  spec.files         = Dir[
    "lib/**/*.rb",
    "lib/**/*.rake",
    "lib/**/*.md",
    "exe/**/*",
    "GUIDES/**/*.md",
    "docs_site/**/*",
    "README.md",
    "LICENSE",
    "CHANGELOG.md",
    "CONTRIBUTING.md",
    "CODE_OF_CONDUCT.md",
    "ARCHITECTURE.md"
  ].reject { |f| f.match?(/\.yardoc|doc\//) }
  
  spec.require_paths = ["lib"]
  
  # Add executables
  spec.executables = ["rails_a11y", "rails_server_safe"]

  # Runtime dependencies
  spec.add_dependency "axe-core-capybara", "~> 4.0"
  spec.add_dependency "capybara", "~> 3.0"
  
  # Optional dependencies (users can choose RSpec or Minitest)
  # spec.add_dependency "rspec-rails", ">= 6.0"  # Optional - user provides

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "yard", "~> 0.9"
  
  # Metadata for RubyGems
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rayraycodes.github.io/rails-accessibility-testing/"
  spec.metadata["rubygems_mfa_required"] = "true"
end

