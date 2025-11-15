---
layout: default
title: Home
---

# Rails Accessibility Testing

**The RSpec + RuboCop of accessibility for Rails. Catch WCAG violations before they reach production.**

Rails Accessibility Testing is a comprehensive accessibility testing gem that makes accessibility testing as natural as unit testing. It integrates seamlessly into your Rails workflow, catching WCAG 2.1 AA violations as you code—not after deployment.

## Quick Start

```ruby
# Add to Gemfile
group :development, :test do
  gem 'rails_accessibility_testing'
  gem 'axe-core-capybara', '~> 4.0'
end
```

```bash
# Install
bundle install

# Setup
rails generate rails_a11y:install

# Run tests
bundle exec rspec spec/system/
```

## Features

- **Zero Configuration** - Works out of the box with smart defaults
- **11+ Comprehensive Checks** - WCAG 2.1 AA aligned
- **Actionable Error Messages** - Code examples showing how to fix issues
- **RSpec & Minitest** - Works with both test frameworks
- **CLI Tool** - Command-line interface for scanning URLs and routes
- **YAML Configuration** - Profile-based configuration for different environments

## Documentation

- [Getting Started]({{ '/getting_started.html' | relative_url }}) - Quick start guide
- [Configuration]({{ '/configuration.html' | relative_url }}) - Configuration options
- [CI Integration]({{ '/ci_integration.html' | relative_url }}) - CI/CD setup
- [Contributing]({{ '/contributing.html' | relative_url }}) - How to contribute

## Links

- [GitHub Repository](https://github.com/rayraycodes/rails-accessibility-testing)
- [RubyGems](https://rubygems.org/gems/rails_accessibility_testing)
- [Issue Tracker](https://github.com/rayraycodes/rails-accessibility-testing/issues)
- [Changelog](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/CHANGELOG.md)

