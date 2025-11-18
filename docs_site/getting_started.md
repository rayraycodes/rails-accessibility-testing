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
    
    # Run comprehensive accessibility checks
    # This will fail the test if any accessibility issues are found
    check_comprehensive_accessibility
    # ✅ If all checks pass, you'll see: "All comprehensive accessibility checks passed! (11 checks)"
  end
end
```

### Step 4: Run Your Tests

You can run accessibility checks in several ways:

#### Option A: Run Tests Manually

```bash
bundle exec rspec spec/system/
```

Accessibility checks run automatically on every system test that visits a page.

#### Option B: Run Continuously with Procfile (Recommended for Development)

For continuous accessibility checking during development, add to your `Procfile.dev`:

```procfile
web: bin/rails server
css: bin/rails dartsass:watch
a11y: while true; do bundle exec rspec spec/system/*_accessibility_spec.rb; sleep 30; done
```

Then run:

```bash
bin/dev
```

This will:
- Start your Rails server
- Watch for CSS changes
- **Automatically run accessibility checks every 30 seconds** on all `*_accessibility_spec.rb` files

The accessibility checker will continuously monitor your pages and alert you to any issues as you develop!

## Learn More

- **[System Specs Guide](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/GUIDES/system_specs_for_accessibility.md)** - ⭐ Recommended approach for reliable accessibility testing
- **[Complete Getting Started Guide](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/GUIDES/getting_started.md)** - Detailed setup instructions

