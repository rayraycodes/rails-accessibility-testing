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
  gem 'axe-core-capybara', '~> 4.0'
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.0'
  gem 'webdrivers', '~> 5.0'  # Optional but recommended for automatic driver management
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
- Updates `spec/rails_helper.rb` (if using RSpec)

### Step 2.5: Configure Capybara Driver (Required for System Tests)

For system tests to work, you need to configure Capybara with a Selenium driver. Create `spec/support/driver.rb`:

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

### Step 3: Install Chrome/Chromium (Required)

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

## Your First Accessibility Check

Let's see it in action. Create a simple system spec:

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

While checks run automatically after each `visit`, you can also run comprehensive checks explicitly at any point in your test:

```ruby
# spec/system/home_page_accessibility_spec.rb
require 'rails_helper'

RSpec.describe 'Home Page Accessibility', type: :system do
  it 'loads the page and runs comprehensive accessibility checks' do
    visit root_path
    expect(page).to have_content('Welcome')
    
    # Run comprehensive accessibility checks explicitly
    # This will fail the test if any accessibility issues are found
    check_comprehensive_accessibility
    # ✅ This runs all 11 comprehensive checks:
    #    - Form labels, Image alt text, Interactive elements
    #    - Heading hierarchy, Keyboard accessibility, ARIA landmarks
    #    - Form errors, Table structure, Duplicate IDs
    #    - Skip links, Color contrast (if enabled)
    # If all checks pass, you'll see: "All comprehensive accessibility checks passed! (11 checks)"
  end
end
```

**When to use explicit checks:**
- When you want to run checks at a specific point in your test (e.g., after filling a form)
- When you want to ensure checks run even if the test might fail before the automatic check
- When you want to test multiple pages in one spec and check each one explicitly

**Note:** Even if you call `check_comprehensive_accessibility` explicitly, the automatic checks will still run after the test completes (unless the test fails before reaching the explicit check).

### Example: Comprehensive Check Output

If there are accessibility issues, you'll see detailed error messages like:

```
======================================================================
❌ ACCESSIBILITY ERROR: Image missing alt attribute
======================================================================

📄 Page Being Tested:
   URL: http://localhost:3000/
   Path: /
   📝 Likely View File: app/views/pages/home.html.erb

📍 Element Details:
   Tag: <img>
   ID: (none)
   Classes: logo
   Src: /assets/logo.png

🔧 HOW TO FIX:
   Choose ONE of these solutions:

   1. Add alt text for informative images:
      <img src="/assets/logo.png" alt="Company Logo">

   2. Use Rails image_tag helper:
      <%= image_tag 'logo.png', alt: 'Company Logo' %>

   💡 Best Practice: All images must have alt attribute.
      Use empty alt="" only for purely decorative images.
```

## Understanding the Checks

Rails A11y runs **11 comprehensive checks** automatically. These checks are WCAG 2.1 AA aligned:

1. **Form Labels** - All form inputs have associated labels
2. **Image Alt Text** - All images have descriptive alt attributes (including empty alt="" detection)
3. **Interactive Elements** - Buttons, links, and other interactive elements have accessible names
4. **Heading Hierarchy** - Proper h1-h6 structure without skipping levels
5. **Keyboard Accessibility** - All interactive elements are keyboard accessible
6. **ARIA Landmarks** - Proper use of ARIA landmark roles for page structure
7. **Form Error Associations** - Form errors are properly linked to their form fields
8. **Table Structure** - Tables have proper headers and structure
9. **Duplicate IDs** - No duplicate ID attributes on the page
10. **Skip Links** - Skip navigation links are present for keyboard users
11. **Color Contrast** - Text meets WCAG contrast requirements (optional, disabled by default for performance)

### What `check_comprehensive_accessibility` Does

When you call `check_comprehensive_accessibility`, it runs all 11 checks above and provides detailed error messages for any violations found. Each error includes:

- **File location hints** - Know exactly which view file to fix
- **Element details** - Tag, ID, classes, and visible text
- **Actionable fix instructions** - Code examples showing how to fix the issue
- **WCAG references** - Links to relevant WCAG guidelines

If all checks pass, you'll see:
```
✅ All comprehensive accessibility checks passed! (11 checks)
```

## Configuration

### Basic Configuration

Edit `config/accessibility.yml`:

```yaml
wcag_level: AA

checks:
  form_labels: true
  image_alt_text: true
  # ... other checks
  color_contrast: false  # Disabled by default (expensive)
```

### Profile-Specific Configuration

Different settings for different environments:

```yaml
development:
  checks:
    color_contrast: false  # Skip in dev for speed

ci:
  checks:
    color_contrast: true   # Full checks in CI
```

### Ignoring Rules Temporarily

Sometimes you need to temporarily ignore a rule while fixing issues:

```yaml
ignored_rules:
  - rule: form_labels
    reason: "Legacy form, scheduled for refactor in Q2"
    comment: "Will be fixed in PR #123"
```

**Important:** Always include a reason and plan to fix. This is for temporary exceptions, not permanent workarounds.

## Skipping Checks in Tests

Sometimes you need to skip accessibility checks for specific tests:

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
1. Make sure Chrome is installed (see Step 3 above)
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

| Component | Recommended Version | Minimum Version |
|-----------|-------------------|-----------------|
| Ruby | 3.1+ | 3.0+ |
| Rails | 7.1+ / 8.0+ | 6.0+ |
| RSpec Rails | 6.0+ | 5.0+ |
| Capybara | ~> 3.40 | 3.0+ |
| selenium-webdriver | ~> 4.10 | 4.0+ |
| webdrivers | ~> 5.3 | 5.0+ |

**Rails 8 Notes:**
- Rails 8 requires `selenium-webdriver` 4.6.0+ for `DriverFinder` support
- Make sure your `driven_by` configuration is in `spec/support/driver.rb`
- Rails 8 system tests use `driven_by` instead of direct Capybara configuration

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

