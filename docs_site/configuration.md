---
layout: default
title: Configuration
---

# Configuration

Rails Accessibility Testing works out of the box with zero configuration, but you can customize it to fit your needs.

## YAML Configuration

Create `config/accessibility.yml` in your Rails app:

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

test:
  checks:
    # Test environment uses global settings by default

ci:
  checks:
    color_contrast: true   # Full checks in CI

# Ignored rules with reasons
ignored_rules:
  # - rule: form_labels
  #   reason: "Legacy form, scheduled for refactor in Q2"
  #   comment: "Will be fixed in PR #123"
```

## Ruby Configuration

Edit `config/initializers/rails_a11y.rb`:

```ruby
RailsAccessibilityTesting.configure do |config|
  # Automatically run checks after system specs
  config.auto_run_checks = true
  
  # Logger for accessibility check output
  config.logger = Rails.logger
  
  # Configuration file path (relative to Rails.root)
  config.config_path = 'config/accessibility.yml'
  
  # Default profile to use (development, test, ci)
  config.default_profile = :test
end
```

## Profiles

Use different configurations for different environments:

- **development**: Faster checks, skip expensive operations
- **test**: Default settings, balanced checks
- **ci**: Full checks, strict validation

Set the profile via environment variable:

```bash
RAILS_A11Y_PROFILE=ci bundle exec rspec spec/system/
```

## Ignoring Rules

Temporarily ignore specific rules while fixing issues:

```yaml
ignored_rules:
  - rule: form_labels
    reason: "Legacy form, scheduled for refactor in Q2"
    comment: "Will be fixed in PR #123"
```

**Important:** Always include a reason and plan to fix. This is for temporary exceptions, not permanent workarounds.

## Skipping Checks in Tests

Skip accessibility checks for specific tests:

```ruby
# RSpec
it "does something", skip_a11y: true do
  # Accessibility checks won't run
end

# Minitest
test "does something", skip_a11y: true do
  # Accessibility checks won't run
end
```

