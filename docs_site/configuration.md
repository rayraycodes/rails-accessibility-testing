---
layout: default
title: Configuration
---

# Configuration

You can customize how the gem works by creating a `config/accessibility.yml` file.

---

## Quick Start Configuration

Here is a recommended configuration file that works for most Rails apps:

```yaml
# config/accessibility.yml

# Compliance Goal (A, AA, or AAA)
wcag_level: AA

# Enable/Disable specific checks
checks:
  form_labels: true
  image_alt_text: true
  interactive_elements: true
  heading: true
  keyboard_accessibility: true
  aria_landmarks: true
  form_errors: true
  table_structure: true
  duplicate_ids: true
  skip_links: true
  color_contrast: false  # Disabled by default (slow)

# Static Scanner (for bin/dev)
static_scanner:
  scan_changed_only: true
  check_interval: 3
  full_scan_on_startup: true

# Reporting
summary:
  show_summary: true
  show_fixes: true
  ignore_warnings: false
```

---

## Profiles (Environments)

You often want different rules for Development vs. CI. You can define profiles in the same file:

```yaml
# ... base config above ...

development:
  checks:
    color_contrast: false  # Fast scans in dev
  static_scanner:
    scan_changed_only: true

ci:
  checks:
    color_contrast: true   # Full check in CI
    skip_links: true       # Strict requirements
  summary:
    ignore_warnings: true  # Only fail on errors
```

To run a specific profile:
```bash
RAILS_A11Y_PROFILE=ci bundle exec rspec
```

---

## Ignoring Specific Rules

Sometimes you have legacy code that you can't fix right away. You can ignore specific rules with a reason:

```yaml
ignored_rules:
  - rule: form_labels
    reason: "Legacy login form, scheduled for redesign"
  - rule: contrast
    reason: "Brand colors need update from design team"
```

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
