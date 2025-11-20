# frozen_string_literal: true

require_relative "lib/rails_accessibility_testing/version"

Gem::Specification.new do |spec|
  spec.name          = "rails_accessibility_testing"
  spec.version       = RailsAccessibilityTesting::VERSION   
  spec.authors       = ["Regan Maharjan"]
  spec.email         = ["imregan@umich.edu"]

  spec.summary       = "The RSpec + RuboCop of accessibility for Rails. Catch WCAG violations before they reach production."
  spec.description   = "Comprehensive, opinionated but configurable accessibility testing gem for Rails. Integrates seamlessly into your test suite with RSpec and Minitest support. Includes CLI tool, Rails generator, YAML configuration, and 11+ WCAG 2.1 AA aligned checks with actionable error messages."
  spec.homepage      = "https://rayraycodes.github.io/rails-accessibility-testing/"
  spec.license       = "MIT"

  # Include all necessary files
  spec.files         = Dir[
    "lib/**/*.rb",
    "lib/**/*.rake",
    "lib/**/*.md",
    "lib/**/*.erb",  # Include ERB templates for generators
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
  
  # Add executables (they're in exe/ directory)
  spec.bindir = "exe"
  spec.executables = ["rails_a11y", "rails_server_safe", "a11y_live_scanner"]

  # Runtime dependencies
  # Only essential dependencies for RSpec system specs
  spec.add_dependency "axe-core-capybara", "~> 4.0"
  
  # Optional dependencies (users provide these in their own Gemfile)
  # - rspec-rails (for RSpec integration)
  # - capybara (for system specs - users configure their own drivers)
  # - selenium-webdriver (only needed if using CLI tool, which users can opt into)

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  
  # Metadata for RubyGems
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rayraycodes/rails-accessibility-testing"
  spec.metadata["changelog_uri"] = "https://github.com/rayraycodes/rails-accessibility-testing/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rayraycodes.github.io/rails-accessibility-testing/"
  spec.metadata["rubygems_mfa_required"] = "true"
end

