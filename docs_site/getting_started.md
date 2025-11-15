---
layout: default
title: Getting Started
---

# Getting Started with Rails Accessibility Testing

Welcome to Rails Accessibility Testing! This guide will help you get up and running with accessibility testing in your Rails application in just a few minutes.

## What is Rails Accessibility Testing?

Rails Accessibility Testing is an accessibility testing gem that automatically checks your Rails views for WCAG 2.1 AA compliance. Think of it as RSpec + RuboCop for accessibility—it catches violations as you code, not after deployment.

## Quick Start (5 Minutes)

### Step 1: Install the Gem

Add to your `Gemfile`:

```ruby
group :development, :test do
  gem 'rails_accessibility_testing'
  gem 'axe-core-capybara', '~> 4.0'
end
```

Then run:

```bash
bundle install
```

### Step 2: Run the Generator

```bash
rails generate rails_a11y:install
```

**Note:** The generator uses the short name `rails_a11y` for convenience. The gem name is `rails_accessibility_testing`.

This creates:
- `config/initializers/rails_a11y.rb` - Configuration
- `config/accessibility.yml` - Check settings
- Updates `spec/rails_helper.rb` (if using RSpec)

### Step 3: Run Your Tests

That's it! Just run your system specs:

```bash
bundle exec rspec spec/system/
```

Accessibility checks run automatically on every system test that visits a page.

For complete documentation, see the [Getting Started guide](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/GUIDES/getting_started.md) in the main repository.

