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

### Step 3: Create System Specs (Recommended)

Create system specs for the pages you want to test. This is the **recommended and most reliable** approach:

```ruby
# spec/system/home_page_accessibility_spec.rb
require 'rails_helper'

RSpec.describe 'Home Page Accessibility', type: :system do
  it 'loads the page and runs comprehensive accessibility checks' do
    visit root_path
    # ✅ Comprehensive accessibility checks run automatically!
    # The test will fail if any accessibility issues are found
  end
end
```

### Step 4: Run Your Tests

```bash
bundle exec rspec spec/system/
```

Accessibility checks run automatically on every system test that visits a page.

## Learn More

- **[System Specs Guide](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/GUIDES/system_specs_for_accessibility.md)** - ⭐ Recommended approach for reliable accessibility testing
- **[Complete Getting Started Guide](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/GUIDES/getting_started.md)** - Detailed setup instructions

