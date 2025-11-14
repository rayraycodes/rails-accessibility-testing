# Rails Accessibility Testing Gem

**Automatic accessibility testing for Rails system specs - zero configuration, zero code changes needed!**

---

## 🚀 Quick Start (2 Steps)

### Step 1: Add Gem Dependency
```ruby
# Gemfile
group :development, :test do
  gem 'axe-core-capybara'
end
```
Run: `bundle install`

### Step 2: Require the Gem
```ruby
# spec/rails_helper.rb (after require 'rspec/rails')
require 'rails_accessibility_testing'
```

**That's it!** Accessibility checks now run automatically on all system specs.

---

## 📚 Complete Documentation

**For full setup, dependencies, and configuration:**

👉 **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Complete setup and configuration guide  
👉 **[DEPENDENCIES.md](DEPENDENCIES.md)** - Detailed dependencies and requirements

---

## ✨ How It Works

**No code changes needed!** Just put specs in `spec/system/` and they're automatically system specs:

```ruby
# spec/system/my_page_spec.rb
# No type: :system needed - detected automatically from file location!
RSpec.describe "My Page" do
  before { visit some_path }
  
  it "does something" do
    expect(page).to have_content("something")
    # ✅ Accessibility checks run automatically (only when code changes!)
  end
end
```

**Automatic detection:** The gem automatically:
- ✅ Detects system specs by file location (`spec/system/`)
- ✅ Applies accessibility checks to all system specs
- ✅ No `type: :system` needed (but works if you add it)
- ✅ No `include_examples` needed
- ✅ No manual check calls needed

**Smart change detection:** Checks only run when relevant code has changed (views, controllers, helpers). This makes tests faster!

After each system spec that visits a page, if code changed, **comprehensive accessibility checks** run automatically (all 11 checks):
- ✅ Form labels
- ✅ Image alt text
- ✅ Interactive element names
- ✅ Heading hierarchy
- ✅ Keyboard accessibility
- ✅ ARIA landmarks
- ✅ Form error associations
- ✅ Table structure
- ✅ Custom element labels
- ✅ Duplicate IDs
- ✅ Skip links

If issues are found, the test fails with detailed error messages showing:
- 📄 Which file to fix
- 📍 Element details
- 🔧 Step-by-step remediation

---

## 🎯 Features

- ✅ **Fully automatic** - No code changes needed in specs
- ✅ **Auto-detects system specs** - By file location (`spec/system/`)
- ✅ **11 comprehensive checks** with detailed errors
- ✅ **File location hints** - Know exactly which view to fix
- ✅ **Remediation steps** - Code examples showing how to fix
- ✅ **Smart change detection** - Only runs when code changes
- ✅ **Zero configuration** - Just require and it works

---

## 🔍 Error Messages

Every error includes:
- 📄 Page URL and view file location
- 📍 Element details (tag, ID, classes, parent)
- 🔧 Step-by-step fix instructions with code
- 💡 Best practices

---

## 🏃 Running Tests

```bash
# Run all system tests (accessibility checks run automatically)
bundle exec rspec spec/system/

# Auto-runs in dev (every 30s)
bin/dev

# Manual check
bundle exec ruby lib/rails_accessibility_testing/dev_checker.rb
```

---

## ⚙️ Advanced Usage

### Skip Checks for Specific Tests

```ruby
it "does something", skip_a11y: true do
  # Accessibility checks won't run
end
```

### Manual Comprehensive Checks

```ruby
it "meets all standards" do
  check_comprehensive_accessibility  # All 11 checks
end
```

---

## 📦 What's Included

- `accessibility_helper.rb` - All 11 check functions
- `shared_examples.rb` - Reusable test patterns (optional)
- `dev_checker.rb` - Dev console checker
- Complete documentation

**Everything in one gem - automatic and zero configuration!**

---

## 📖 Next Steps

1. Read **[SETUP_GUIDE.md](SETUP_GUIDE.md)** for complete setup instructions
2. Check **[DEPENDENCIES.md](DEPENDENCIES.md)** for dependency details
3. Write your specs in `spec/system/` - checks run automatically!

---

## Requirements Summary

**Required Gems:**
- `axe-core-capybara` - Automated WCAG checks
- `rspec-rails` - Testing framework
- `capybara` - Browser automation
- `webdrivers` - Browser driver management

**System Requirements:**
- Ruby 3.0+ (3.1+ recommended)
- Rails 6.0+ (7.1+ recommended)
- Chrome/Chromium browser

See **[DEPENDENCIES.md](DEPENDENCIES.md)** for complete details.
