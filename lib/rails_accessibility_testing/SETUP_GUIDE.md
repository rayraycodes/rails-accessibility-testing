# Rails Accessibility Testing Gem - Complete Setup Guide

## Table of Contents

1. [Overview](#overview)
2. [Dependencies](#dependencies)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Usage](#usage)
6. [How It Works](#how-it-works)
7. [Troubleshooting](#troubleshooting)
8. [Advanced Configuration](#advanced-configuration)

---

## Overview

The Rails Accessibility Testing gem provides **automatic accessibility testing** for Rails system specs. It runs WCAG 2.1 AA compliance checks automatically when code changes, with detailed error messages and remediation guidance.

### Key Features

- ✅ **Fully automatic** - No code changes needed in specs
- ✅ **Smart change detection** - Only runs when code changes
- ✅ **11 comprehensive checks** - Covers all major accessibility concerns
- ✅ **Detailed error messages** - Shows file location and fix instructions
- ✅ **Zero configuration** - Works out of the box
- ✅ **WCAG 2.1 AA compliant** - Industry standard accessibility

---

## Dependencies

### Required Gems

#### 1. `axe-core-capybara`
**Purpose:** Automated accessibility testing using axe-core engine  
**Version:** Latest stable  
**What it does:** Provides `be_axe_clean` matcher for automated WCAG checks

```ruby
gem 'axe-core-capybara'
```

#### 2. RSpec Rails
**Purpose:** Testing framework  
**Version:** 8.0+ recommended  
**What it does:** Provides system spec infrastructure

```ruby
gem 'rspec-rails', '~> 8.0.0'
```

#### 3. Capybara
**Purpose:** Browser automation for system tests  
**Version:** 3.40+  
**What it does:** Enables page interaction and testing

```ruby
gem 'capybara', '~> 3.40'
```

#### 4. Webdrivers
**Purpose:** Browser driver management  
**Version:** 5.3.0+  
**What it does:** Manages Chrome/Firefox drivers for system tests

```ruby
gem 'webdrivers', '= 5.3.0'
```

### Optional Dependencies

- **Selenium WebDriver** - Usually included with Capybara
- **Chrome/Chromium** - Required for headless browser testing
- **Git** - Used for change detection (falls back to file timestamps if unavailable)

### System Requirements

- **Ruby:** 3.0+ (recommended 3.1+)
- **Rails:** 6.0+ (tested on 7.1+)
- **Browser:** Chrome/Chromium for headless testing
- **OS:** macOS, Linux, or Windows with WSL

---

## Installation

### Step 1: Add Dependencies to Gemfile

Add the required gem to your `Gemfile`:

```ruby
group :development, :test do
  gem 'axe-core-capybara'
  # Other existing gems...
  gem 'rspec-rails', '~> 8.0.0'
  gem 'capybara', '~> 3.40'
  gem 'webdrivers', '= 5.3.0'
end
```

### Step 2: Install Gems

Run bundle install:

```bash
bundle install
```

### Step 3: Copy the Gem to Your Project

The gem files should be in `lib/rails_accessibility_testing/`. If not, copy the entire directory:

```
lib/
  rails_accessibility_testing/
    ├── accessibility_helper.rb
    ├── shared_examples.rb
    ├── dev_checker.rb
    ├── rails_accessibility_testing.rb
    └── version.rb
```

### Step 4: Require the Gem in rails_helper.rb

In `spec/rails_helper.rb`, add after `require 'rspec/rails'`:

```ruby
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Auto-configure accessibility testing
require 'rails_accessibility_testing'
```

### Step 5: Verify Installation

Run a test to verify everything works:

```bash
bundle exec rspec spec/system/ --dry-run
```

You should see no errors. If you see errors, check the [Troubleshooting](#troubleshooting) section.

---

## Configuration

### Automatic Configuration

The gem **auto-configures everything** when required. No manual configuration needed!

When you `require 'rails_accessibility_testing'`, it automatically:

1. ✅ Loads `axe-core-capybara` matchers
2. ✅ Includes `AccessibilityHelper` in all system specs
3. ✅ Sets up automatic accessibility checks
4. ✅ Configures change detection

### Optional: Manual Configuration

If you need to customize behavior, you can modify `lib/rails_accessibility_testing.rb`:

#### Change Detection Time Window

Default: 5 minutes. To change:

```ruby
# In lib/rails_accessibility_testing.rb, line ~65
return true if mtime > (Time.now - 300) # Change 300 to desired seconds
```

#### Skip Checks for Specific Tests

Add metadata to skip checks:

```ruby
it "does something", skip_a11y: true do
  # Accessibility checks won't run
end
```

#### Force Checks to Run

Manually call checks:

```ruby
it "does something" do
  check_basic_accessibility  # Force checks to run
end
```

---

## Usage

### Basic Usage (Automatic)

**No code changes needed!** Just write your normal system specs:

```ruby
RSpec.describe "My Page", type: :system do
  before do
    visit some_path
  end
  
  it "does something" do
    expect(page).to have_content("something")
    # ✅ Accessibility checks run automatically (only when code changes!)
  end
end
```

### Manual Checks

If you want to run checks manually:

```ruby
it "meets accessibility standards" do
  check_basic_accessibility  # 5 basic checks
  # or
  check_comprehensive_accessibility  # All 11 checks
end
```

### Individual Checks

Run specific checks:

```ruby
it "has proper form labels" do
  check_form_labels
end

it "has alt text on images" do
  check_image_alt_text
end
```

### Shared Examples (Optional)

Use shared examples for explicit testing:

```ruby
include_examples "a page with basic accessibility"
include_examples "a page with comprehensive accessibility"
```

---

## How It Works

### Automatic Check Flow

1. **System spec runs** - Your normal test executes
2. **Test completes** - If test passes and page was visited
3. **Change detection** - Checks if relevant files changed:
   - View file modification time (last 5 minutes)
   - Git status for uncommitted changes
   - File system scan for recent changes
4. **Checks run** - If changes detected, runs 5 basic checks:
   - Form labels
   - Image alt text
   - Interactive element names
   - Heading hierarchy
   - Keyboard accessibility
5. **Error reporting** - If issues found, test fails with detailed error

### Change Detection

Checks only run when:
- ✅ View files modified in last 5 minutes
- ✅ Git shows uncommitted changes in `app/views/`, `app/controllers/`, `app/helpers/`
- ✅ Any view/controller/helper file modified recently

Checks skip when:
- ❌ No files have changed
- ❌ Code is unchanged
- ❌ Running tests on existing code

### Available Checks

#### Basic Checks (5)
1. `check_form_labels` - Form inputs have labels
2. `check_image_alt_text` - Images have alt attributes
3. `check_interactive_elements_have_names` - Buttons/links have names
4. `check_heading_hierarchy` - Proper heading structure
5. `check_keyboard_accessibility` - Keyboard navigation

#### Advanced Checks (6)
6. `check_aria_landmarks` - ARIA landmarks present
7. `check_form_error_associations` - Errors associated with inputs
8. `check_table_structure` - Tables have headers
9. `check_custom_element_labels` - Custom elements labeled
10. `check_duplicate_ids` - No duplicate IDs
11. `check_skip_links` - Skip links present

---

## Troubleshooting

### Issue: "cannot load such file -- axe-core-capybara"

**Solution:** Make sure the gem is in your Gemfile and run `bundle install`:

```bash
bundle install
```

### Issue: "uninitialized constant Axe::Matchers"

**Solution:** The gem should auto-configure. Check that `require 'rails_accessibility_testing'` is in `rails_helper.rb` after `require 'rspec/rails'`.

### Issue: "NoMethodError: undefined method 'be_axe_clean'"

**Solution:** Ensure `axe-core-capybara` is installed:

```bash
bundle install
```

### Issue: Tests are slow

**Solution:** This is expected - accessibility checks add time. The gem only runs checks when code changes to minimize impact. If still slow:
- Use `skip_a11y: true` for non-critical tests
- Run checks manually only when needed
- Adjust change detection time window

### Issue: Checks not running

**Possible causes:**
1. **No code changes** - Checks only run when files change
2. **Not a system spec** - Checks only run on `type: :system` specs
3. **Page not visited** - Checks only run if `visit` was called

**Solution:** Force checks to run:

```ruby
it "does something" do
  check_basic_accessibility
end
```

### Issue: Browser not found

**Solution:** Install Chrome/Chromium:

```bash
# macOS
brew install --cask google-chrome

# Linux (Ubuntu/Debian)
sudo apt-get install chromium-browser

# Or use Firefox
# Update spec/support/driver.rb to use Firefox
```

### Issue: Git change detection not working

**Solution:** This is fine - the gem falls back to file modification times. Git is optional.

---

## Advanced Configuration

### Custom Change Detection

Modify `files_changed?` method in `lib/rails_accessibility_testing.rb`:

```ruby
def self.files_changed?(current_path)
  # Your custom logic
  # Return true to run checks, false to skip
end
```

### Custom Error Messages

Modify `build_error_message` in `lib/rails_accessibility_testing/accessibility_helper.rb`:

```ruby
def build_error_message(error_type, element_context, page_context, remediation_steps)
  # Your custom error message format
end
```

### Environment-Specific Behavior

Check environment in your code:

```ruby
# In rails_helper.rb or initializer
if Rails.env.test?
  # Test-specific configuration
end
```

### CI/CD Integration

For CI, you may want to always run checks:

```ruby
# In lib/rails_accessibility_testing.rb
def self.files_changed?(current_path)
  # Always run in CI
  return true if ENV['CI']
  
  # Normal change detection for local
  # ... existing code ...
end
```

---

## File Structure

```
lib/rails_accessibility_testing/
├── rails_accessibility_testing.rb    # Main gem file (auto-configuration)
├── accessibility_helper.rb            # All 11 check functions
├── shared_examples.rb                 # RSpec shared examples
├── dev_checker.rb                     # Dev console checker
├── version.rb                         # Gem version
└── README.md                          # This file
```

---

## Dependencies Summary

| Dependency | Purpose | Required |
|------------|---------|----------|
| `axe-core-capybara` | Automated WCAG checks | ✅ Yes |
| `rspec-rails` | Testing framework | ✅ Yes |
| `capybara` | Browser automation | ✅ Yes |
| `webdrivers` | Browser driver management | ✅ Yes |
| `selenium-webdriver` | Browser control | ✅ Yes (via Capybara) |
| Git | Change detection | ⚠️ Optional (falls back) |
| Chrome/Chromium | Browser for tests | ✅ Yes |

---

## Quick Start Checklist

- [ ] Add `gem 'axe-core-capybara'` to Gemfile
- [ ] Run `bundle install`
- [ ] Copy `lib/rails_accessibility_testing/` directory
- [ ] Add `require 'rails_accessibility_testing'` to `rails_helper.rb`
- [ ] Verify with `bundle exec rspec spec/system/ --dry-run`
- [ ] Write a system spec and see checks run automatically!

---

## Support

For issues or questions:
1. Check [Troubleshooting](#troubleshooting) section
2. Review gem code in `lib/rails_accessibility_testing/`
3. Check RSpec and Capybara documentation

---

## License

MIT - Use freely in your projects!

