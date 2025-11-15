# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-14

### Added
- Initial release of Rails Accessibility Testing gem
- Automatic accessibility checking for Rails system specs
- 11+ comprehensive accessibility checks:
  - Form labels
  - Image alt text
  - Interactive element names
  - Heading hierarchy
  - Keyboard accessibility
  - ARIA landmarks
  - Form error associations
  - Table structure
  - Duplicate IDs
  - Skip links
  - Color contrast (optional)
- Rule engine architecture for extensible checks
- YAML configuration system with profile support (development, test, ci)
- CLI tool (`rails_a11y`) for checking URLs and routes
- Rails generator (`rails generate rails_a11y:install`) for easy setup
- RSpec integration with automatic hooks
- Minitest integration for system tests
- Automatic system spec detection by file location
- Smart change detection (only runs when code changes)
- Detailed error messages with file locations and remediation steps
- WCAG 2.1 AA compliance references
- Zero-configuration setup with sensible defaults
- Skip checks for specific tests via `skip_a11y: true` metadata
- Manual comprehensive check method `check_comprehensive_accessibility`
- Comprehensive documentation:
  - Getting Started guide
  - Continuous Integration guide
  - Writing Accessible Views guide
  - Working with Designers guide
  - Architecture documentation
- Error message builder with semantic element names
- View file detection including partials and layouts
- Batch error collection (reports all errors, not just first)
- Human-readable and JSON report formats
- Profile-based configuration for different environments

### Technical Details
- Built on axe-core-capybara for WCAG testing
- Integrates with RSpec Rails and Minitest
- Uses Capybara for browser automation
- Supports Rails 6.0+ and Ruby 3.0+
- Compatible with RSpec Rails 6.0+
- Modular architecture with rule engine and check definitions

[1.0.0]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.0.0

