# Rails Accessibility Testing

[![Gem Version](https://badge.fury.io/rb/rails_accessibility_testing.svg)](https://badge.fury.io/rb/rails_accessibility_testing)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby Version](https://img.shields.io/badge/ruby-3.0%2B-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/rails-6.0%2B-red.svg)](https://rubyonrails.org/)

**Zero-configuration accessibility testing for Rails system specs. Automatically checks for WCAG 2.1 AA compliance with detailed, actionable error messages.**

## ✨ Features

- 🚀 **Fully Automatic** - No code changes needed in your specs
- 🎯 **11 Comprehensive Checks** - Covers all major accessibility concerns
- 📍 **File Location Hints** - Know exactly which view file to fix
- 🔧 **Remediation Steps** - Code examples showing how to fix issues
- ⚡ **Smart Change Detection** - Only runs when relevant code changes
- 📝 **Detailed Error Messages** - Actionable feedback with WCAG references
- 🎨 **Zero Configuration** - Just require and it works

## 🚀 Quick Start

### Installation

Add to your `Gemfile`:

```ruby
group :development, :test do
  gem 'rails_accessibility_testing'
  gem 'axe-core-capybara'
end
```

Then run:

```bash
bundle install
```

### Setup

Add to your `spec/rails_helper.rb`:

```ruby
require 'rspec/rails'
require 'rails_accessibility_testing'  # Add this line
```

**That's it!** Accessibility checks now run automatically on all system specs.

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
it "does something", skip_a11y: true do
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
9. ✅ **Custom Element Labels** - Custom components have labels
10. ✅ **Duplicate IDs** - No duplicate ID attributes
11. ✅ **Skip Links** - Skip navigation links present

## 📋 Example Error Output

When accessibility issues are found, you get detailed, actionable errors:

```
Accessibility Violations Found on /home

Summary:
  1. Missing form label
  2. Image missing alt text
  3. Button missing accessible name

Details:

1. Missing Form Label
   File: app/views/users/_form.html.erb (line 5)
   Element: <input type="text" id="user_email" name="user[email]">
   
   Fix:
   1. Add a label element before the input:
      <%= form.label :email, "Email Address" %>
      <%= form.text_field :email %>
   
   WCAG Reference: 1.3.1 Info and Relationships (Level A)

2. Image Missing Alt Text
   File: app/views/shared/_header.html.erb (line 12)
   Element: <img src="/logo.png" class="logo">
   
   Fix:
   1. Add alt attribute:
      <%= image_tag "logo.png", alt: "Company Logo", class: "logo" %>
   
   WCAG Reference: 1.1.1 Non-text Content (Level A)
```

## 📚 Documentation

- **[SETUP_GUIDE.md](lib/rails_accessibility_testing/SETUP_GUIDE.md)** - Complete setup and configuration guide
- **[DEPENDENCIES.md](lib/rails_accessibility_testing/DEPENDENCIES.md)** - Detailed dependencies and requirements
- **[MANAGER_OVERVIEW.md](lib/rails_accessibility_testing/MANAGER_OVERVIEW.md)** - High-level overview for managers
- **[FLOW_DIAGRAM.md](lib/rails_accessibility_testing/FLOW_DIAGRAM.md)** - Technical flow diagrams

## 🔧 Configuration

The gem works out of the box with zero configuration. Optional configuration:

```ruby
# config/initializers/rails_accessibility_testing.rb (optional)
RailsAccessibilityTesting.configure do |config|
  config.auto_run_checks = true  # Default: true
end
```

## 🏗️ How It Works

1. **Automatic Detection** - Detects system specs by file location (`spec/system/`)
2. **Change Detection** - Only runs checks when relevant code (views, controllers, helpers) has changed
3. **Comprehensive Checks** - Runs all 11 accessibility checks automatically
4. **Error Reporting** - Collects all errors and reports them with file locations and fix instructions

## 📦 Requirements

- Ruby 3.0+ (3.1+ recommended)
- Rails 6.0+ (7.1+ recommended)
- RSpec Rails 6.0+
- Capybara 3.0+
- Chrome/Chromium browser

See [DEPENDENCIES.md](lib/rails_accessibility_testing/DEPENDENCIES.md) for complete details.

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on [axe-core](https://github.com/dequelabs/axe-core) for accessibility testing
- Uses [axe-core-capybara](https://github.com/dequelabs/axe-core-capybara) for Capybara integration
- Inspired by the need for better accessibility testing in Rails applications

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/rayraycodes/rails-accessibility-testing/issues)
- **Email:** imregan@umich.edu

## 🗺️ Roadmap

- [ ] Support for additional accessibility standards
- [ ] Custom check configuration
- [ ] CI/CD integration examples
- [ ] Performance optimizations
- [ ] Additional documentation and examples

---

**Made with ❤️ for accessible Rails applications**
