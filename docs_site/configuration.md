---
layout: default
title: Configuration
---

# Configuration

You can customize how the gem works by creating a `config/accessibility.yml` file.

---

## Quick Start Configuration

Here is the configuration file structure that gets generated when you run the installer:

```yaml
# config/accessibility.yml

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
RailsAccessibilityTesting.configure do |config|
  config.auto_run_checks = true  # Note: Can be overridden by YAML config
  config.logger = Rails.logger
  config.default_profile = :test
end
```

**Important:** The YAML `system_specs.auto_run` setting takes precedence over `config.auto_run_checks` from the initializer. Use YAML for environment-specific control.
