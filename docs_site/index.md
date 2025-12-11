---
layout: default
title: Home
---

# Rails Accessibility Testing

**The RSpec + RuboCop of accessibility for Rails. Catch WCAG violations before they reach production.**

**Version:** 1.6.0

Rails Accessibility Testing is a comprehensive, opinionated but configurable gem that makes accessibility testing as natural as unit testing. It integrates seamlessly into your Rails workflow, catching accessibility issues as you code—not after deployment.

## 🎯 Positioning

Rails Accessibility Testing fills a critical gap in the Rails testing ecosystem. While RSpec ensures code works and RuboCop ensures code style, Rails Accessibility Testing ensures applications are accessible to everyone. Unlike manual accessibility audits that happen late in development, Rails Accessibility Testing integrates directly into your test suite, catching violations as you code. It's opinionated enough to guide teams new to accessibility, yet configurable enough for experienced teams. By making accessibility testing as natural as unit testing, Rails Accessibility Testing helps teams build accessible applications from day one, not as an afterthought.

## ✨ Features

### Core Capabilities
- 🚀 **Zero Configuration** - Works out of the box with smart defaults
- 🎯 **11+ Comprehensive Checks** - WCAG 2.1 AA aligned
- 📍 **Precise File Location** - Know exactly which view file or partial to fix
- 🔧 **Actionable Error Messages** - Code examples showing how to fix issues
- 🎨 **Beautiful CLI** - Human-readable and JSON reports
- 🔌 **Rails Generator** - One command setup
- 🧪 **RSpec & Minitest** - Works with both test frameworks
- ⚙️ **YAML Configuration** - Profile-based config (dev/test/CI)

### 🆕 Version 1.5.0+ Highlights

#### 🔍 Static File Scanner (NEW)
- **Fast file-based scanning**: Scans ERB templates directly without browser rendering
- **Smart change detection**: Only scans files that have changed since last scan
- **Precise error reporting**: Shows exact file locations and line numbers
- **Continuous monitoring**: Watches for file changes and re-scans automatically
- **YAML configuration**: Fully configurable via `config/accessibility.yml`
- **Reuses existing checks**: Leverages all 11 accessibility checks via RuleEngine
- **Intelligent ERB handling**: Correctly processes dynamic IDs and ERB expressions
  - Preserves structure of dynamic IDs (e.g., `collection_answers_<%= question.id %>_<%= option.id %>_`)
  - Matches labels to inputs with dynamic IDs
  - Excludes dynamic IDs from duplicate checking (prevents false positives)

#### 🎯 Live Accessibility Scanner
- **Real-time scanning**: Automatically scans pages as you browse during development
- **Smart cancellation**: Cancels scans when you navigate to new pages, focusing on current page
- **Integrated workflow**: Works seamlessly with `bin/dev` via Procfile.dev
- **Detailed reporting**: Shows exactly what's being scanned with page URLs and view files

#### 📝 Enhanced Error Reporting
- **View file priority**: Rails view files shown prominently instead of URLs
- **Comprehensive summaries**: Overall test report showing all pages tested with statistics
- **Accurate error counting**: Properly tracks and displays error/warning counts
- **Persistent output**: Errors stay visible in terminal (no clearing)

## 🚀 Quick Start

### Installation

Add to your `Gemfile`:

```ruby
group :development, :test do
  gem 'rails_accessibility_testing'
  gem 'rspec-rails', '~> 8.0'  # Required for system specs
  gem 'axe-core-capybara', '~> 4.0'
  gem 'capybara', '~> 3.40'
  gem 'selenium-webdriver', '~> 4.0'
  gem 'webdrivers', '~> 5.0'  # Optional but recommended
  gem 'csv'  # Required for Ruby 3.3+ (CSV removed from standard library in Ruby 3.4)
end
```

**Important:** You must explicitly add `selenium-webdriver` and `csv` (for Ruby 3.3+) to your Gemfile. The gem has minimal dependencies - you control your own driver setup.

Then run:

```bash
bundle install
```

### Setup (Option 1: Generator - Recommended)

```bash
rails generate rails_a11y:install
```

This creates:
- `config/initializers/rails_a11y.rb` - Configuration
- `config/accessibility.yml` - Check settings
- `spec/system/all_pages_accessibility_spec.rb` - Comprehensive spec that dynamically tests all GET routes
- Updates `spec/rails_helper.rb` (if using RSpec)
- Updates `Procfile.dev` with static accessibility scanner (`a11y_static_scanner`)

## 📖 Usage

### System Specs (Recommended)

**System specs are the recommended and most reliable way to run accessibility checks.** They're faster, more reliable, and integrate seamlessly with your test suite.

Create system specs for your pages:

```ruby
# spec/system/home_page_accessibility_spec.rb
require 'rails_helper'

RSpec.describe 'Home Page Accessibility', type: :system do
  it 'loads successfully and passes comprehensive accessibility checks' do
    visit root_path
    expect(page).to have_content('Welcome')
    
    # Run comprehensive accessibility checks
    check_comprehensive_accessibility
    # ✅ Comprehensive accessibility checks (11 checks) also run automatically after this test!
  end
end
```

**Accessibility checks run automatically after each `visit` in system specs!**

### Continuous Development Testing

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

## 🎯 What Gets Checked

The gem automatically runs **11 comprehensive accessibility checks**:

1. ✅ **Form Labels** - All form inputs have associated labels (handles dynamic IDs from ERB templates)
2. ✅ **Image Alt Text** - All images have descriptive alt attributes
3. ✅ **Interactive Elements** - Buttons, links have accessible names (including links with images that have alt text; correctly handles links with `href="#"`)
4. ✅ **Heading Hierarchy** - Proper h1-h6 structure (detects missing h1, multiple h1s, skipped levels, and h2+ without h1)
5. ✅ **Keyboard Accessibility** - All interactive elements keyboard accessible
6. ✅ **ARIA Landmarks** - Proper use of ARIA landmark roles
7. ✅ **Form Error Associations** - Errors linked to form fields
8. ✅ **Table Structure** - Tables have proper headers
9. ✅ **Duplicate IDs** - No duplicate ID attributes (intelligently handles dynamic IDs from ERB templates)
10. ✅ **Skip Links** - Skip navigation links present (detects various patterns)
11. ✅ **Color Contrast** - Text meets contrast requirements (optional)

## 📚 Documentation

- [Getting Started]({{ '/getting_started.html' | relative_url }}) - Quick start guide
- [Architecture]({{ '/architecture.html' | relative_url }}) - Visual diagrams and internal architecture
- [Configuration]({{ '/configuration.html' | relative_url }}) - Configuration options
- [CI Integration]({{ '/ci_integration.html' | relative_url }}) - CI/CD setup
- [Contributing]({{ '/contributing.html' | relative_url }}) - How to contribute

### Additional Guides

- [System Specs for Accessibility](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/GUIDES/system_specs_for_accessibility.md) - ⭐ Recommended approach
- [Writing Accessible Views](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/GUIDES/writing_accessible_views_in_rails.md) - Best practices
- [Working with Designers](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/GUIDES/working_with_designers_and_content_authors.md) - Team collaboration

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/rayraycodes/rails-accessibility-testing/issues)
- **Email:** imregan@umich.edu
- **Documentation:** See [GUIDES](GUIDES/) directory

---

**Made with ❤️ for accessible Rails applications**

*Rails Accessibility Testing helps teams build accessible applications from day one, not as an afterthought.*
