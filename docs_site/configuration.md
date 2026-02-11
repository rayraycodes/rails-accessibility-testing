---
layout: default
title: Configuration
---

# Configuration

You can customize how the gem works by creating a `config/accessibility.yml` file.

---

## 🚨 Production Deployment Safety

**Important:** The gem is designed to be excluded from production environments. By default, accessibility tests are disabled to prevent them from running in production or blocking CI/CD pipelines.

### Production Safety Features

1. **Disabled by Default** - `accessibility_enabled: false` prevents tests from running automatically
2. **Production Guard** - Initializer includes `if defined?(RailsAccessibilityTesting)` check
3. **Gem Exclusion** - Gem should be in `:development, :test` group only

### Recommended Production Setup

**In your `Gemfile`:**
```ruby
group :development, :test do
  gem 'rails_accessibility_testing'
  # ... other test gems
end
```

**In `config/accessibility.yml`:**
```yaml
# Disabled by default - prevents CI/CD failures and production execution
accessibility_enabled: false
```

**In `config/initializers/rails_a11y.rb`:**
```ruby
# Production safety guard - prevents errors if gem not available
if defined?(RailsAccessibilityTesting)
  RailsAccessibilityTesting.configure do |config|
    config.auto_run_checks = false
  end
end
```

**Why this matters:**
- ✅ Prevents accessibility tests from blocking CI/CD pipelines
- ✅ Safe deployment even if gem configuration exists
- ✅ No errors if gem is excluded from production bundle
- ✅ Manual testing available: `rspec spec/accessibility/all_pages_accessibility_spec.rb`

📖 **See [Best Practices Guide](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/GUIDES/best_practices.md) for detailed production configuration recommendations.**

---

## Quick Start Configuration

Here is the configuration file structure that gets generated when you run the installer:

```yaml
# config/accessibility.yml

# Global enable/disable flag for all accessibility checks
# Set to false to completely disable all accessibility checks (manual and automatic)
# When false, check_comprehensive_accessibility and automatic checks will be skipped
# Default: false 
#   (Set to false to allow other RSpec tests to pass in GitHub Actions CI even if accessibility tests fail.
#    When true, any failing accessibility tests will cause the entire CI pipeline to fail.)
# Set to true to run accessibility checks manually: rspec spec/accessibility/all_pages_accessibility_spec.rb
accessibility_enabled: false

# WCAG compliance level (A, AA, AAA)
wcag_level: AA

# Summary configuration
# Control how accessibility test summaries are displayed
summary:
  # Show summary at end of test suite (true/false)
  show_summary: true
  
  # Show only errors in summary, hide warnings (true/false)
  errors_only: false
  
  # Show fix suggestions in error messages (true/false)
  show_fixes: true
  
  # Ignore warnings completely - only show errors (true/false)
  ignore_warnings: false

# Scanning strategy
# 'paths' - Scan by visiting routes/paths (default)
# 'view_files' - Scan by finding view files and visiting their routes
scan_strategy: 'view_files'

# Static scanner configuration
# Controls behavior of the static file scanner (a11y_static_scanner)
static_scanner:
  # Only scan files that have changed since last scan (true/false)
  scan_changed_only: true
  
  # Check interval in seconds when running continuously
  check_interval: 3
  
  # Force full scan on startup (true/false)
  full_scan_on_startup: true

# System specs configuration
# Controls behavior of accessibility checks in RSpec system specs
system_specs:
  # Automatically run accessibility checks after each system spec (true/false)
  # When true, checks run automatically after each `visit` in system specs
  # When false, checks only run when explicitly called (e.g., check_comprehensive_accessibility)
  # Can be overridden per-profile (see profile sections below)
  auto_run: true

# Global check configuration
# Set to false to disable a check globally
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
  color_contrast: false  # Disabled by default (requires JS evaluation)
```

---

## Profiles (Environments)

You can define different configurations for different environments:

```yaml
# ... base config above ...

development:
  checks:
    color_contrast: false  # Skip in dev for speed
  # system_specs:
  #   auto_run: false  # Disable auto-run in development for faster tests

test:
  checks:
    # Test environment uses global settings by default
  # system_specs:
  #   auto_run: true  # Enable auto-run in test (default)

ci:
  checks:
    color_contrast: true   # Full checks in CI
  # system_specs:
  #   auto_run: true  # Always run in CI
```

To run a specific profile:
```bash
RAILS_A11Y_PROFILE=ci bundle exec rspec
```

---

## Ignoring Specific Rules

Temporarily ignore specific rules while fixing issues:

```yaml
ignored_rules:
  - rule: form_labels
    reason: "Legacy form, scheduled for refactor in Q2"
    comment: "Will be fixed in PR #123"
```

**Important:** Always include a reason and plan to fix. This is for temporary exceptions, not permanent workarounds.

---

## System Specs Configuration

Control whether accessibility checks run automatically in system specs:

```yaml
# config/accessibility.yml
system_specs:
  auto_run: true  # Run checks automatically (default: true)
```

**When `auto_run: true`** (default):
- Checks run automatically after each `visit` in system specs
- No need to manually call `check_comprehensive_accessibility`
- Great for continuous testing

**When `auto_run: false`**:
- Checks only run when explicitly called
- Use `check_comprehensive_accessibility` in your specs
- Useful when you want more control over when checks run

**Profile-specific overrides:**

```yaml
development:
  system_specs:
    auto_run: false  # Disable in development for faster tests

test:
  system_specs:
    auto_run: true   # Always run in test environment

ci:
  system_specs:
    auto_run: true   # Always run in CI
```

**Note:** YAML configuration takes precedence over the Ruby initializer configuration. If `system_specs.auto_run` is set in YAML, it will override `config.auto_run_checks` from the initializer.

---

## Ruby Configuration

For advanced setup (like changing the logger), create an initializer:

```ruby
# config/initializers/rails_a11y.rb

# Production safety guard - prevents errors if gem not available in production
if defined?(RailsAccessibilityTesting)
  RailsAccessibilityTesting.configure do |config|
    # Automatically run checks after system specs
    # Set to false to disable automatic checks (recommended)
    config.auto_run_checks = false  # Note: Can be overridden by YAML config
    
    # Logger for accessibility check output
    # Set to nil to use default logger
    # config.logger = Rails.logger
    
    # Configuration file path (relative to Rails.root)
    # config.config_path = 'config/accessibility.yml'
  
    # Default profile to use (development, test, ci)
    # config.default_profile = :test
  end
end
```

**Production Safety:** The `if defined?(RailsAccessibilityTesting)` guard ensures the configuration only loads if the gem is available, preventing errors in production environments where the gem may be excluded.

**Important:** The YAML `system_specs.auto_run` setting takes precedence over `config.auto_run_checks` from the initializer. Use YAML for environment-specific control.
