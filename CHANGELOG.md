# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2024-12-XX

### Changed
- **BREAKING**: Removed unnecessary dependencies (selenium-webdriver, capybara from gemspec)
- Gem now has minimal dependencies - only requires `axe-core-capybara`
- Users provide their own capybara, selenium-webdriver, webdrivers in their Gemfile
- This allows users to control their own driver configuration for RSpec system specs
- CLI tool still works but requires users to have selenium-webdriver in their Gemfile if they want to use it

## [1.1.6] - 2024-12-XX

### Fixed
- Added server readiness check with retry mechanism to prevent connection refused errors
- CLI tool now waits up to 20 seconds for Rails server to be ready before attempting accessibility checks
- Prevents race conditions when running in Procfile.dev where a11y process starts before web server

## [1.1.5] - 2024-12-XX

### Fixed
- Fixed CLI tool "invalid argument" error when visiting paths by automatically converting paths to full URLs
- CLI tool now properly constructs `http://localhost:PORT/path` URLs when using Selenium with Rails apps
- Respects PORT, RAILS_PORT, and RAILS_URL environment variables for server URL configuration

## [1.1.4] - 2024-12-XX

### Fixed
- Fixed CLI tool chromedriver discovery issue by automatically requiring webdrivers gem when available
- CLI tool now works properly with projects that use webdrivers for driver management

## [1.1.3] - 2024-12-XX

### Fixed
- Fixed CLI tool (`rails_a11y`) failing when RSpec is not available by conditionally loading RSpec-specific components
- CLI tool can now run independently without requiring RSpec to be loaded

## [1.1.0] - 2024-11-15

### Added
- GitHub Pages documentation site with Jekyll
- Comprehensive GitHub Actions workflow for automatic documentation deployment
- Enhanced workflow diagnostics and verification steps
- Test step to verify index.html exists before deployment
- Improved error messages and troubleshooting guides
- Token support for GitHub Pages deployment (OIDC with PAT fallback)

### Improved
- Better artifact structure verification in CI/CD
- Enhanced deployment diagnostics
- More detailed build output and verification steps
- Improved documentation structure and organization

### Fixed
- Jekyll build configuration and dependencies
- GitHub Pages deployment path isolation
- Artifact structure for subdirectory deployment

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

[1.2.0]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.2.0
[1.1.6]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.1.6
[1.1.5]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.1.5
[1.1.4]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.1.4
[1.1.3]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.1.3
[1.1.0]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.1.0
[1.0.0]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.0.0

