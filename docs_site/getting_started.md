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
  gem 'rspec-rails', '~> 8.0'  # Required for system specs
  gem 'axe-core-capybara', '~> 4.0'
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.0'
  gem 'webdrivers', '~> 5.0'  # Optional but recommended for automatic driver management
end
```

**Important:** 
- You must explicitly add `selenium-webdriver` to your Gemfile. It's not automatically included as a dependency.
- **RSpec Rails is required** - The generator creates system specs that require `rspec-rails`. If you're using Minitest, you'll need to manually create your accessibility tests.

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
- `spec/system/all_pages_accessibility_spec.rb` - Comprehensive spec that tests all GET routes
- Updates `spec/rails_helper.rb` (if using RSpec)

### Step 3: Run Your Tests

The generator creates `spec/system/all_pages_accessibility_spec.rb` which automatically tests all GET routes in your application.

You can also create custom system specs for specific pages:

```ruby
# spec/system/my_page_accessibility_spec.rb
require 'rails_helper'

RSpec.describe 'My Page Accessibility', type: :system do
  it 'loads the page and runs comprehensive accessibility checks' do
    visit root_path
    
    # Run comprehensive accessibility checks
    # This will fail the test if any accessibility issues are found
    check_comprehensive_accessibility
    # ✅ If all checks pass, you'll see: "All comprehensive accessibility checks passed! (11 checks)"
  end
end
```

### Step 5: Run Your Tests

You can run accessibility checks in several ways:

#### Option A: Run Tests Manually

```bash
# Run all accessibility specs
bundle exec rspec spec/system/*_accessibility_spec.rb

# Or run all system specs
bundle exec rspec spec/system/
```

Accessibility checks run automatically on every system test that visits a page.


## Troubleshooting

### How do I configure Capybara for system tests?

If you don't already have system tests configured, you need to set up Capybara with a Selenium driver. Create `spec/support/driver.rb`:

```ruby
# spec/support/driver.rb
require 'selenium-webdriver'
require 'capybara/rails'
require 'capybara/rspec'

# Configure Chrome options
browser_options = Selenium::WebDriver::Chrome::Options.new
browser_options.add_argument('--window-size=1920,1080')
browser_options.add_argument('--headless') unless ENV['SHOW_TEST_BROWSER']

# Register the driver
Capybara.register_driver :selenium_chrome_headless do |app|
  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: browser_options
  )
end

# Set as default JavaScript driver
Capybara.javascript_driver = :selenium_chrome_headless

# Configure RSpec to use the driver for system tests
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end
end
```

**Note for Rails 8:** Rails 8 uses `driven_by` to configure system tests. Make sure your `spec/support/driver.rb` is loaded by `rails_helper.rb` (it should be automatically loaded if it's in the `spec/support/` directory).

### How do I install Chrome/Chromium?

System tests require Chrome or Chromium to be installed on your system:

**macOS:**
```bash
brew install --cask google-chrome
# or for Chromium:
brew install --cask chromium
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y google-chrome-stable
# or for Chromium:
sudo apt-get install -y chromium-browser
```

**Windows:**
Download and install Chrome from [google.com/chrome](https://www.google.com/chrome/)

The `webdrivers` gem will automatically download and manage the ChromeDriver binary for you.

### Error: `uninitialized constant Selenium::WebDriver::DriverFinder`

This error typically occurs when:
1. **Missing selenium-webdriver gem** - Make sure you've added `gem 'selenium-webdriver', '~> 4.0'` to your Gemfile
2. **Version incompatibility** - Ensure you're using compatible versions:
   - `selenium-webdriver` ~> 4.0 (4.6.0+ recommended for Rails 8)
   - `webdrivers` ~> 5.0 (if using webdrivers)
   - `capybara` ~> 3.40

**Solution:**
```bash
# Update your Gemfile
gem 'selenium-webdriver', '~> 4.10'
gem 'webdrivers', '~> 5.3'
gem 'capybara', '~> 3.40'

# Then run
bundle update selenium-webdriver webdrivers capybara
```

### Error: Chrome/ChromeDriver not found

**Solution:**
1. Make sure Chrome is installed (see Step 2.5 above)
2. If using `webdrivers` gem, it should auto-download ChromeDriver. If not:
   ```bash
   bundle exec webdrivers chrome
   ```
3. For manual installation, download from [ChromeDriver downloads](https://chromedriver.chromium.org/downloads)

### System tests not running

**Check:**
1. Your spec has `type: :system` metadata
2. `spec/support/driver.rb` exists and is properly configured
3. `spec/rails_helper.rb` loads support files (should be automatic)
4. Chrome is installed and accessible

### Tests are slow

Disable expensive checks in development:
```yaml
# config/accessibility.yml
development:
  checks:
    color_contrast: false  # Disable expensive color contrast checks
```

## Version Compatibility

For best results, use these compatible versions:

| Component | Recommended Version | Minimum Version | Required |
|-----------|-------------------|-----------------|----------|
| Ruby | 3.1+ | 3.0+ | Yes |
| Rails | 7.1+ / 8.0+ | 6.0+ | Yes |
| **RSpec Rails** | **8.0+** | **6.0+** | **Yes (for system specs)** |
| Capybara | ~> 3.40 | 3.0+ | Yes |
| selenium-webdriver | ~> 4.10 | 4.0+ | Yes |
| webdrivers | ~> 5.3 | 5.0+ | Optional |

**Rails 8 Notes:**
- Rails 8 requires `selenium-webdriver` 4.6.0+ for `DriverFinder` support
- Make sure your `driven_by` configuration is in `spec/support/driver.rb`
- Rails 8 system tests use `driven_by` instead of direct Capybara configuration

## Learn More

- **[System Specs Guide](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/GUIDES/system_specs_for_accessibility.md)** - ⭐ Recommended approach for reliable accessibility testing
- **[Complete Getting Started Guide](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/GUIDES/getting_started.md)** - Detailed setup instructions

