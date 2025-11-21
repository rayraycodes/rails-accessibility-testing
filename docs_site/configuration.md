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

test:
  checks:
    # Test environment uses global settings by default

ci:
  checks:
    color_contrast: true   # Full checks in CI
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

## Ruby Configuration

For advanced setup (like changing the logger), create an initializer:

```ruby
# config/initializers/rails_a11y.rb
RailsAccessibilityTesting.configure do |config|
  config.auto_run_checks = true
  config.logger = Rails.logger
  config.default_profile = :test
end
```
