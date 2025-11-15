# Rails Accessibility Testing

[![Gem Version](https://badge.fury.io/rb/rails_accessibility_testing.svg)](https://badge.fury.io/rb/rails_accessibility_testing)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby Version](https://img.shields.io/badge/ruby-3.0%2B-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/rails-6.0%2B-red.svg)](https://rubyonrails.org/)

**The RSpec + RuboCop of accessibility for Rails. Catch WCAG violations before they reach production.**

Rails Accessibility Testing is a comprehensive, opinionated but configurable gem that makes accessibility testing as natural as unit testing. It integrates seamlessly into your Rails workflow, catching accessibility issues as you code—not after deployment.

## 🎯 Positioning

Rails Accessibility Testing fills a critical gap in the Rails testing ecosystem. While RSpec ensures code works and RuboCop ensures code style, Rails Accessibility Testing ensures applications are accessible to everyone. Unlike manual accessibility audits that happen late in development, Rails Accessibility Testing integrates directly into your test suite, catching violations as you code. It's opinionated enough to guide teams new to accessibility, yet configurable enough for experienced teams. By making accessibility testing as natural as unit testing, Rails Accessibility Testing helps teams build accessible applications from day one, not as an afterthought.

## ✨ Features

- 🚀 **Zero Configuration** - Works out of the box with smart defaults
- 🎯 **11+ Comprehensive Checks** - WCAG 2.1 AA aligned
- 📍 **File Location Hints** - Know exactly which view file to fix
- 🔧 **Actionable Error Messages** - Code examples showing how to fix issues
- ⚡ **Smart Change Detection** - Only runs when relevant code changes
- 🎨 **Beautiful CLI** - Human-readable and JSON reports
- 🔌 **Rails Generator** - One command setup
- 🧪 **RSpec & Minitest** - Works with both test frameworks
- ⚙️ **YAML Configuration** - Profile-based config (dev/test/CI)
- 📚 **Comprehensive Guides** - Learn as you go

## 🚀 Quick Start

### Installation

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

### Setup (Option 1: Generator - Recommended)

```bash
rails generate rails_a11y:install
```

**Note:** The generator command is `rails_a11y:install` (short form). The gem name is `rails_accessibility_testing`.

This creates:
- `config/initializers/rails_a11y.rb` - Configuration
- `config/accessibility.yml` - Check settings
- Updates `spec/rails_helper.rb` (if using RSpec)

### Setup (Option 2: Manual)

Add to your `spec/rails_helper.rb` (RSpec):

```ruby
require 'rspec/rails'
require 'rails_accessibility_testing'  # Add this line
```

Or for Minitest, add to `test/test_helper.rb`:

```ruby
require 'rails_accessibility_testing/integration/minitest_integration'
RailsAccessibilityTesting::Integration::MinitestIntegration.setup!
```

**That's it!** Accessibility checks now run automatically on all system tests.

## 📖 Usage

### Automatic Checks

Just write your specs normally - checks run automatically:

```ruby
# spec/system/home_page_spec.rb
RSpec.describe "Home Page" do
  it "displays welcome message" do
    visit root_path
    expect(page).to have_content("Welcome")
    # ✅ Accessibility checks run automatically!
  end
end
```

### Skip Checks for Specific Tests

```ruby
# RSpec
it "does something", skip_a11y: true do
  # Accessibility checks won't run for this test
end

# Minitest
test "does something", skip_a11y: true do
  # Accessibility checks won't run for this test
end
```

### Manual Comprehensive Checks

```ruby
it "meets all accessibility standards" do
  visit some_path
  check_comprehensive_accessibility  # All 11 checks
end
```

### CLI Usage

Run checks against URLs or Rails routes:

```bash
# Check specific paths
bundle exec rails_a11y check /home /about

# Check URLs
bundle exec rails_a11y check --urls https://example.com

# Check Rails routes
bundle exec rails_a11y check --routes home_path about_path

# Generate JSON report
bundle exec rails_a11y check --format json --output report.json

# Use CI profile
bundle exec rails_a11y check --profile ci
```

## 🎯 What Gets Checked

The gem automatically runs **11 comprehensive accessibility checks**:

1. ✅ **Form Labels** - All form inputs have associated labels
2. ✅ **Image Alt Text** - All images have descriptive alt attributes
3. ✅ **Interactive Elements** - Buttons, links have accessible names
4. ✅ **Heading Hierarchy** - Proper h1-h6 structure
5. ✅ **Keyboard Accessibility** - All interactive elements keyboard accessible
6. ✅ **ARIA Landmarks** - Proper use of ARIA landmark roles
7. ✅ **Form Error Associations** - Errors linked to form fields
8. ✅ **Table Structure** - Tables have proper headers
9. ✅ **Duplicate IDs** - No duplicate ID attributes
10. ✅ **Skip Links** - Skip navigation links present
11. ✅ **Color Contrast** - Text meets contrast requirements (optional)

## ⚙️ Configuration

### YAML Configuration

Create `config/accessibility.yml`:

```yaml
# WCAG compliance level (A, AA, AAA)
wcag_level: AA

# Global check configuration
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

# Profile-specific configurations
development:
  checks:
    color_contrast: false  # Skip in dev for speed

ci:
  checks:
    color_contrast: true   # Full checks in CI

# Ignored rules with reasons
ignored_rules:
  # - rule: form_labels
  #   reason: "Legacy form, scheduled for refactor in Q2"
  #   comment: "Will be fixed in PR #123"
```

### Ruby Configuration

Edit `config/initializers/rails_a11y.rb`:

```ruby
RailsAccessibilityTesting.configure do |config|
  # Automatically run checks after system specs
  config.auto_run_checks = true
  
  # Logger for accessibility check output
  config.logger = Rails.logger
  
  # Configuration file path
  config.config_path = 'config/accessibility.yml'
  
  # Default profile
  config.default_profile = :test
end
```

## 📋 Example Error Output

When accessibility issues are found, you get detailed, actionable errors:

```
======================================================================
❌ ACCESSIBILITY ERROR: Image missing alt attribute
======================================================================

📄 Page Being Tested:
   URL: http://localhost:3000/
   Path: /
   📝 Likely View File: app/views/shared/_header.html.erb

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

📖 WCAG Reference: https://www.w3.org/WAI/WCAG21/Understanding/
======================================================================
```

## 📚 Documentation

### Online Documentation

📖 **[View Full Documentation on GitHub Pages](https://rayraycodes.github.io/rails-accessibility-testing/)** - Complete documentation site with all guides and examples

### Guides

- **[Getting Started](GUIDES/getting_started.md)** - Quick start guide
- **[Continuous Integration](GUIDES/continuous_integration.md)** - CI/CD setup
- **[Writing Accessible Views](GUIDES/writing_accessible_views_in_rails.md)** - Best practices
- **[Working with Designers](GUIDES/working_with_designers_and_content_authors.md)** - Team collaboration

### API Documentation

Generate API docs with YARD:

```bash
bundle exec yard doc
```

View at `doc/index.html`

## 🏗️ Architecture

Rails Accessibility Testing is built with a clean, modular architecture:

- **Rule Engine** - Evaluates accessibility checks
- **Check Definitions** - WCAG-aligned check implementations
- **Violation Collector** - Aggregates and formats violations
- **Rails Integration** - Railtie, RSpec, Minitest helpers
- **CLI** - Command-line interface for URL/route scanning
- **Configuration** - YAML-based config with profiles

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture documentation.

## 🔧 Requirements

- Ruby 3.0+ (3.1+ recommended)
- Rails 6.0+ (7.1+ recommended)
- RSpec Rails 6.0+ (for RSpec) or Minitest (for Minitest)
- Capybara 3.0+
- Chrome/Chromium browser

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add: amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on [axe-core](https://github.com/dequelabs/axe-core) for accessibility testing
- Uses [axe-core-capybara](https://github.com/dequelabs/axe-core-capybara) for Capybara integration
- Inspired by the need for better accessibility testing in Rails applications

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/rayraycodes/rails-accessibility-testing/issues)
- **Email:** imregan@umich.edu
- **Documentation:** See [GUIDES](GUIDES/) directory

## 🗺️ Roadmap

- [ ] Enhanced color contrast checking with JS evaluation
- [ ] Custom rule definitions
- [ ] Visual regression testing
- [ ] Performance monitoring
- [ ] IDE integration (VS Code, IntelliJ)
- [ ] CI/CD templates (GitHub Actions, CircleCI)

---

**Made with ❤️ for accessible Rails applications**

*Rails Accessibility Testing helps teams build accessible applications from day one, not as an afterthought.*
