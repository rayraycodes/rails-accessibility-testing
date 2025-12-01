# Rails Accessibility Testing

[![Gem Version](https://badge.fury.io/rb/rails_accessibility_testing.svg)](https://badge.fury.io/rb/rails_accessibility_testing)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ruby Version](https://img.shields.io/badge/ruby-3.0%2B-red.svg)](https://www.ruby-lang.org/)
[![Rails Version](https://img.shields.io/badge/rails-6.0%2B-red.svg)](https://rubyonrails.org/)

**The RSpec + RuboCop of accessibility for Rails. Catch WCAG violations before they reach production.**

**Current Version:** 1.5.9

📖 **[📚 Full Documentation](https://rayraycodes.github.io/rails-accessibility-testing/)** | [💻 GitHub](https://github.com/rayraycodes/rails-accessibility-testing) | [💎 RubyGems](https://rubygems.org/gems/rails_accessibility_testing)

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

#### 🔍 Composed Page Scanning (NEW in 1.5.9+)
- **Complete page analysis**: Analyzes full page composition (layout + view + partials) for page-level checks
- **Eliminates false positives**: No more false positives when H1 is in layout or partials
- **Exhaustive partial finding**: Traverses ALL folders recursively to find all partials
- **Works for any structure**: General solution that works for any Rails folder structure (collections, items, profiles, loan_requests, etc.)
- **Page-level checks**: Heading hierarchy, ARIA landmarks, duplicate IDs, and empty headings checked across complete page

#### 🔍 Smart View File Detection
- **Intelligent matching**: Automatically finds view files even when action names don't match
- **Controller directory scanning**: Searches all view files to find the correct template
- **Fuzzy matching**: Handles variations and naming conventions
- **Partial detection**: Shows exact partial file when issues are found

#### ⚡ Performance Optimizations
- **Optimized DOM queries**: Faster image alt checks without JavaScript evaluation
- **Removed delays**: Eliminated unnecessary sleep calls in live scanner
- **Efficient scanning**: ~25-30% faster page scans
- **Optimized directory search**: Returns first match found instead of checking all matches

#### 🎨 Enhanced Developer Experience
- **Real-time progress**: Step-by-step feedback during accessibility checks
- **Clear summaries**: Comprehensive test reports with view files and statistics
- **Better error context**: Shows view files, paths, and element details
- **Focused scanning**: Live scanner adapts to your browsing behavior

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

**Note:** The generator command is `rails_a11y:install` (short form). The gem name is `rails_accessibility_testing`.

This creates:
- `config/initializers/rails_a11y.rb` - Configuration
- `config/accessibility.yml` - Check settings
- `spec/system/all_pages_accessibility_spec.rb` - Comprehensive spec that dynamically tests all GET routes
- Updates `spec/rails_helper.rb` (if using RSpec)
- Updates `Procfile.dev` with static accessibility scanner (`a11y_static_scanner`)
  - Optionally uses `rails_server_safe` wrapper (convenience helper, not required)

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

### All Pages Accessibility Spec

The generator creates `spec/system/all_pages_accessibility_spec.rb` which automatically tests all GET routes in your application. The spec:

- **Dynamically discovers routes** at runtime - works for any Rails app
- **Smart change detection** - Only tests pages when their related files (views, controllers, helpers, CSS/JS) have changed
- **First-run optimization** - Tests all pages on first run, then only changed files
- **Intelligent skipping** - Skips routes that require authentication, have errors, or aren't accessible
- **Friendly summaries** - Shows passed/failed/skipped counts with clear reasons

The spec automatically:
- Tests all GET routes (filters out API, internal Rails routes)
- Handles routes with parameters by substituting test values
- Detects view files even when action names don't match
- Shows which files changed and which pages are affected
- Provides helpful tips and next steps

### Automatic Checks

Just write your specs normally - checks run automatically:

```ruby
# spec/system/home_page_spec.rb
RSpec.describe "Home Page", type: :system do
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

**Configuration** (in `config/accessibility.yml`):

```yaml
static_scanner:
  scan_changed_only: true    # Only scan changed files
  check_interval: 3          # Seconds between file checks
  full_scan_on_startup: true # Full scan on first run
```

The static scanner provides fast, continuous feedback as you develop!

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
3. ✅ **Interactive Elements** - Buttons, links have accessible names (including links with images that have alt text)
4. ✅ **Heading Hierarchy** - Proper h1-h6 structure (detects missing h1, multiple h1s, skipped levels, and h2+ without h1)
5. ✅ **Keyboard Accessibility** - All interactive elements keyboard accessible
6. ✅ **ARIA Landmarks** - Proper use of ARIA landmark roles
7. ✅ **Form Error Associations** - Errors linked to form fields
8. ✅ **Table Structure** - Tables have proper headers
9. ✅ **Duplicate IDs** - No duplicate ID attributes
10. ✅ **Skip Links** - Skip navigation links present (detects various patterns)
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
  heading: true  # Note: renamed from heading_hierarchy in 1.5.0
  keyboard_accessibility: true
  aria_landmarks: true
  form_errors: true
  table_structure: true
  duplicate_ids: true
  skip_links: true
  color_contrast: false  # Disabled by default (expensive)

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
  full_scan_on_startup: true # Full scan on first run

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

When accessibility issues are found, you get detailed, actionable errors with precise file locations:

```
======================================================================
❌ ACCESSIBILITY ERROR: Image missing alt attribute
======================================================================

📄 Page Being Tested:
   URL: http://localhost:3000/items/search
   Path: /items/search
   📝 View File: app/views/items/search_result.html.erb
   📝 Partial: app/views/layouts/_advance_search.html.erb

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

📖 WCAG Reference: https://www.w3.org/WAI/WCAG21/Understanding/non-text-content.html
======================================================================
```

**Notice:** The error shows both the main view file (`search_result.html.erb`) and the partial where the issue actually occurs (`_advance_search.html.erb`). This makes fixing issues much faster!

## 🚀 Performance Features

### Smart Change Detection

The gem automatically detects when files change and only tests affected pages:

- **View files**: Tests pages when their view files change
- **Partials**: Tests pages that render changed partials
- **Controllers**: Tests all routes for a controller when the controller changes
- **Helpers**: Tests all pages when helpers change (they can affect any view)
- **Assets**: Tests all pages when CSS/JS changes (can affect accessibility globally)

### Page Scanning Cache

Prevents duplicate scans of the same page during a test run:

- **Automatic caching**: Each page is scanned once per test suite execution
- **Efficient tracking**: Uses page path or URL as cache key
- **Silent skipping**: Already-scanned pages are skipped without output
- **Manual reset**: Use `reset_scanned_pages_cache` if needed

### First-Run Optimization

- **Initial baseline**: Tests all pages on first run to establish baseline
- **Subsequent runs**: Only tests changed files for faster feedback
- **Marker file**: Creates `.rails_a11y_initialized` to track first run
- **Force all pages**: Set `TEST_ALL_PAGES=true` to test all pages anytime

## 📚 Documentation

### 🌐 Online Documentation

**📖 [View Full Documentation on GitHub Pages](https://rayraycodes.github.io/rails-accessibility-testing/)**

Complete documentation site with all guides, examples, and API reference. The documentation is automatically deployed from this repository.

### 📄 Offline Manual

**[PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md)** - A comprehensive, single-file manual containing all guides, architecture details, and best practices. Perfect for offline reading or sharing as a PDF/DOCX.

> **Note:** 
> - **Documentation URL:** `https://rayraycodes.github.io/rails-accessibility-testing/`
> - If the link doesn't work, GitHub Pages may need to be enabled. See [ENABLE_GITHUB_PAGES.md](ENABLE_GITHUB_PAGES.md) for setup instructions.
> - To add this link to your GitHub repository page, see [GITHUB_REPO_SETUP.md](GITHUB_REPO_SETUP.md)

### Guides

- **[System Specs for Accessibility](GUIDES/system_specs_for_accessibility.md)** - ⭐ **Recommended approach** - Using system specs for reliable accessibility testing
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

- **Rule Engine** - Evaluates accessibility checks with configurable profiles
- **Check Definitions** - WCAG-aligned check implementations (11+ checks)
- **Violation Collector** - Aggregates and formats violations
- **View File Detection** - Intelligent detection of view files and partials
- **Change Detector** - Smart detection of file changes and their impact
- **Page Scanning Cache** - Prevents duplicate scans for performance
- **Static File Scanner** - Fast file-based scanning without browser (NEW in 1.5.3)
- **File Change Tracker** - Tracks file modification times for efficient change detection
- **Rails Integration** - Railtie, RSpec, Minitest helpers
- **CLI** - Command-line interface for URL/route scanning
- **Configuration** - YAML-based config with profiles

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture documentation.

## 🔧 Requirements

- Ruby 3.0+ (3.1+ recommended)
- Rails 6.0+ (7.1+ recommended)
- **RSpec Rails 6.0+ (required for system specs)** or Minitest (for Minitest)
- Capybara 3.0+ (provided by your project)
- selenium-webdriver 4.0+ (provided by your project, for system specs)
- webdrivers (optional, provided by your project, for automatic driver management)
- **csv gem** (required for Ruby 3.3+, as CSV is removed from standard library in Ruby 3.4)
- Chrome/Chromium browser

**Note:** The generator creates system specs that require `rspec-rails`. If you're using Minitest, you'll need to manually create your accessibility tests.

**Note:** As of version 1.2.0, the gem has minimal dependencies. You provide and configure Capybara, selenium-webdriver, webdrivers, and csv in your own Gemfile, giving you full control over your test driver setup.

## 🆕 What's New in 1.5.0

### Major Improvements

1. **🎯 Live Accessibility Scanner**
   - Real-time scanning as you browse during development
   - Integrated with `bin/dev` via Procfile.dev
   - Uses `rails_server_safe` wrapper to prevent Foreman process termination issues
   - Smart cancellation when navigating to new pages
   - Detailed reporting showing exactly what's being scanned

2. **📝 Enhanced Error Reporting**
   - View files shown prominently instead of URLs
   - Comprehensive overall test summaries
   - Accurate error counting and persistent output
   - Better context with view files and element details

3. **🔍 Smart View File Detection**
   - Automatically finds view files even when action names don't match
   - Scans controller directories intelligently
   - Handles edge cases and naming variations
   - Advanced partial detection and mapping

4. **⚡ Performance Optimizations**
   - Page scanning cache prevents duplicate work
   - Smart change detection only tests affected pages
   - First-run optimization for faster initial setup

4. **Enhanced Developer Experience**
   - Friendly test summaries with clear counts and reasons
   - Better error messages with precise file locations
   - Cleaner output with suppressed verbose messages

See [CHANGELOG.md](CHANGELOG.md) for complete details.

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
