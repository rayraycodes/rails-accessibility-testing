# Getting Started with Rails A11y

Welcome to Rails A11y! This guide will help you get up and running with accessibility testing in your Rails application in just a few minutes.

## What is Rails A11y?

Rails A11y is an accessibility testing gem that automatically checks your Rails views for WCAG 2.1 AA compliance. Think of it as RSpec + RuboCop for accessibility—it catches violations as you code, not after deployment.

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
  gem 'webdrivers', '~> 5.0'  # Optional but recommended
end
```

**Important:** You must explicitly add `selenium-webdriver` to your Gemfile. It's not automatically included as a dependency.

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
- Updates `Procfile.dev` - Adds static accessibility scanner

### Step 3: Run Your Tests

#### Option A: Static File Scanner (Recommended for Development)

The generator automatically adds a static accessibility scanner to your `Procfile.dev`:

```procfile
web: bin/rails server
css: bin/rails dartsass:watch
a11y: bundle exec a11y_static_scanner
```

Then run:

```bash
bin/dev
```

This will:
- Start your Rails server
- Watch for CSS changes
- **Continuously scan view files for accessibility issues** - Only scans files that have changed since last scan
- Shows errors with exact file locations and line numbers

**How it works:**
- Scans all files on startup
- Only re-scans files that have been modified
- Watches for file changes and re-scans automatically
- No browser needed - scans ERB templates directly

**Configuration** (in `config/accessibility.yml`):

```yaml
static_scanner:
  scan_changed_only: true    # Only scan changed files
  check_interval: 3          # Seconds between file checks
  full_scan_on_startup: true # Full scan on startup
```

#### Option B: Run Tests Manually

```bash
bundle exec rspec spec/system/
```

Accessibility checks run automatically on every system test that visits a page.

#### Option C: All Pages Spec

Run the comprehensive spec that tests all GET routes:

```bash
bundle exec rspec spec/system/all_pages_accessibility_spec.rb
```

## Your First Accessibility Check

Create a simple system spec:

```ruby
# spec/system/home_spec.rb
RSpec.describe "Home Page", type: :system do
  it "displays the welcome message" do
    visit root_path
    expect(page).to have_content("Welcome")
    # ✅ Accessibility checks run automatically here!
  end
end
```

## Running Comprehensive Checks Explicitly

While checks run automatically after each `visit`, you can also run comprehensive checks explicitly:

```ruby
# spec/system/my_page_accessibility_spec.rb
require 'rails_helper'

RSpec.describe 'My Page Accessibility', type: :system do
  it 'loads the page and runs comprehensive accessibility checks' do
    visit root_path
    check_comprehensive_accessibility  # All 11 checks
  end
end
```

## Understanding the Checks

Rails A11y runs **11 comprehensive checks** automatically. These checks are WCAG 2.1 AA aligned:

1. **Form Labels** - All form inputs have associated labels
2. **Image Alt Text** - All images have descriptive alt attributes
3. **Interactive Elements** - Buttons, links have accessible names
4. **Heading Hierarchy** - Proper h1-h6 structure without skipping levels
5. **Keyboard Accessibility** - All interactive elements are keyboard accessible
6. **ARIA Landmarks** - Proper use of ARIA landmark roles
7. **Form Error Associations** - Form errors are properly linked to form fields
8. **Table Structure** - Tables have proper headers
9. **Duplicate IDs** - No duplicate ID attributes
10. **Skip Links** - Skip navigation links present
11. **Color Contrast** - Text meets WCAG contrast requirements (optional, disabled by default)

## Configuration

Edit `config/accessibility.yml`:

```yaml
wcag_level: AA

# Summary configuration
summary:
  show_summary: true
  errors_only: false
  show_fixes: true
  ignore_warnings: false  # Set to true to hide warnings, only show errors

# Static scanner configuration
static_scanner:
  scan_changed_only: true    # Only scan changed files
  check_interval: 3          # Seconds between file checks
  full_scan_on_startup: true # Full scan on startup

checks:
  form_labels: true
  image_alt_text: true
  interactive_elements: true
  heading_hierarchy: true
  keyboard_accessibility: true
  aria_landmarks: true
  form_errors: true
  table_structure: true
  duplicate_ids: true
  skip_links: true
  color_contrast: false  # Disabled by default (expensive)
```

### Profile-Specific Configuration

```yaml
development:
  checks:
    color_contrast: false  # Skip in dev for speed

ci:
  checks:
    color_contrast: true   # Full checks in CI
```

### Ignoring Rules Temporarily

```yaml
ignored_rules:
  - rule: form_labels
    reason: "Legacy form, scheduled for refactor in Q2"
    comment: "Will be fixed in PR #123"
```

## Skipping Checks in Tests

```ruby
# RSpec
it "does something", skip_a11y: true do
  # Accessibility checks won't run
end

# Minitest
test "does something", skip_a11y: true do
  # Accessibility checks won't run
end
```

## Next Steps

- **⭐ Read the [System Specs Guide](system_specs_for_accessibility.md)** - Recommended approach for reliable accessibility testing
- **Read the [CI Integration Guide](continuous_integration.md)** to set up automated checks
- **Check out [Writing Accessible Views](writing_accessible_views_in_rails.md)** for best practices
- **See [Working with Designers](working_with_designers_and_content_authors.md)** for team collaboration

## Troubleshooting

### How do I configure Capybara for system tests?

Create `spec/support/driver.rb`:

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

# Configure RSpec to use the driver for system tests
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end
end
```

### How do I install Chrome/Chromium?

**macOS:**
```bash
brew install --cask google-chrome
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y google-chrome-stable
```

**Windows:**
Download and install Chrome from [google.com/chrome](https://www.google.com/chrome/)

The `webdrivers` gem will automatically download and manage the ChromeDriver binary for you.

### Error: `uninitialized constant Selenium::WebDriver::DriverFinder`

Make sure you've added `gem 'selenium-webdriver', '~> 4.0'` to your Gemfile and run `bundle install`.

### Error: Chrome/ChromeDriver not found

1. Make sure Chrome is installed
2. If using `webdrivers` gem, it should auto-download ChromeDriver. If not:
   ```bash
   bundle exec webdrivers chrome
   ```

### System tests not running

**Check:**
1. Your spec has `type: :system` metadata
2. `spec/support/driver.rb` exists and is properly configured
3. Chrome is installed and accessible

### Tests are slow

Disable expensive checks in development:

```yaml
# config/accessibility.yml
development:
  checks:
    color_contrast: false  # Disable expensive color contrast checks
```

## Version Compatibility

| Component | Recommended Version | Minimum Version | Required |
|-----------|-------------------|-----------------|----------|
| Ruby | 3.1+ | 3.0+ | Yes |
| Rails | 7.1+ / 8.0+ | 6.0+ | Yes |
| RSpec Rails | 8.0+ | 6.0+ | Yes (for system specs) |
| Capybara | ~> 3.40 | 3.0+ | Yes |
| selenium-webdriver | ~> 4.10 | 4.0+ | Yes |
| webdrivers | ~> 5.3 | 5.0+ | Optional |

## Common Questions

### Q: Do I need to change my existing tests?

**A:** No! Rails A11y works with your existing system tests. Just run them as usual.

### Q: Will this slow down my tests?

**A:** Checks only run when you visit a page in a system test. The checks are fast, and you can disable expensive ones (like color contrast) in development.

### Q: Can I use this with Minitest?

**A:** Yes! See the Minitest integration in the main README.

### Q: What if I disagree with a check?

**A:** You can disable specific checks in `config/accessibility.yml` or ignore specific rules with a reason.

## Getting Help

- **Documentation:** See the main [README](../README.md)
- **Issues:** [GitHub Issues](https://github.com/rayraycodes/rails-accessibility-testing/issues)
- **Email:** imregan@umich.edu

---

**Ready to make your Rails app accessible?** Run your tests and start fixing issues! 🚀
