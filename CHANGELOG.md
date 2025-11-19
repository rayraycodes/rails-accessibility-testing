# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.5.0] - 2025-11-19

### 🎉 Major Release: Enhanced View Detection & Performance Optimizations

This release introduces significant improvements to view file detection, partial scanning, performance optimizations, and developer experience enhancements.

### Added

#### Smart View File Detection
- **Intelligent view file matching**: Automatically detects view files even when action names don't match view file names (e.g., `search` action → `search_result.html.erb`)
- **Controller directory scanning**: Scans all view files in controller directories to find matching templates
- **Fuzzy matching**: Prefers files that start with the action name, handles variations like `search_result`, `search_results`, etc.
- **Single view fallback**: If a controller has only one view file, automatically uses it (useful for single-action controllers)

#### Advanced Partial Detection System
- **Automatic partial discovery**: Scans view files to detect all rendered partials using multiple pattern matching
- **Partial location detection**: Finds partials in controller directories, `shared/`, and `layouts/` directories
- **Namespaced partial support**: Handles partials with paths like `layouts/navbar` or `shared/forms/input`
- **Element-to-partial mapping**: When an accessibility issue is found, automatically determines if it's in a partial and shows the correct file path
- **Multiple render pattern support**: Detects partials rendered via `render 'partial'`, `render partial: 'partial'`, ERB syntax, and more

#### Performance Optimizations
- **Page scanning cache**: Prevents duplicate accessibility scans of the same page during a test run
- **Smart cache key**: Uses page path (preferred) or URL as cache key for efficient tracking
- **Silent skip for cached pages**: Already-scanned pages are skipped silently without output
- **Cache reset helper**: `reset_scanned_pages_cache` method for testing or forced rescans

#### Change Detection Enhancements
- **First-run detection**: Automatically tests all pages on first run, then only changed files on subsequent runs
- **Marker file system**: Creates `.rails_a11y_initialized` marker file to track first run status
- **Asset change detection**: Now detects changes in CSS (`app/assets/`) and JavaScript (`app/javascript/`) files
- **Smart partial impact analysis**: When a partial changes, only tests pages that actually render that partial
- **Layout vs partial distinction**: Main layout files trigger full retest, while specific partials only affect pages that use them
- **Improved route-to-view mapping**: Better handling of routes with `GET|POST` verbs and complex route parameters

#### Enhanced Error Reporting
- **Accurate view file paths**: Error messages now show the exact view file or partial where issues occur
- **Partial context in errors**: When an issue is in a partial, the error message shows both the partial file and the parent view
- **Better route recognition**: Improved mapping of URLs to view files using Rails route recognition
- **View file detection fallbacks**: Multiple fallback strategies ensure view files are found even in edge cases

#### Developer Experience Improvements
- **Friendly test summaries**: Enhanced summary output with passed/failed/skipped counts and reasons
- **Progress indicators**: Real-time progress feedback during accessibility checks
- **Suppressed verbose output**: Cleaner test output with less noise from skipped tests
- **Timestamp formatting**: Human-readable timestamps (HH:MM:SS) in reports instead of full dates
- **CSV warning suppression**: Automatic suppression of Ruby 3.3+ CSV deprecation warnings
- **Better skip reasons**: Clear explanations for why tests are skipped (authentication required, page not found, etc.)

#### Generator Enhancements
- **Dynamic route discovery**: Generated `all_pages_accessibility_spec.rb` now dynamically discovers all GET routes at runtime
- **Generic spec template**: Works for any Rails app without project-specific customization
- **Smart Procfile.dev integration**: Automatically updates `Procfile.dev` with `rails_server_safe` for safe server management
- **Conditional test execution**: Only runs tests when relevant files have changed
- **First-run logic**: Ensures all pages are tested on initial run, then optimizes for subsequent runs

#### Infrastructure Improvements
- **Rails server safe wrapper**: New `rails_server_safe` executable prevents Foreman from terminating all processes when server is already running
- **Improved Procfile.dev command**: More robust `a11y` command with better error handling and output filtering
- **Better RSpec integration**: Enhanced `after(:suite)` hooks for comprehensive test summaries
- **FactoryBot compatibility**: Conditional FactoryBot inclusion to prevent errors when not present

### Changed

#### Heading Check Improvements
- **Renamed to `HeadingCheck`**: More comprehensive check covering all WCAG 2.1 AA heading requirements
- **Multiple h1 detection**: Now correctly detects and reports multiple `<h1>` tags as errors (not warnings)
- **Comprehensive heading validation**: Checks for missing h1, skipped heading levels, empty headings, and headings with images without alt text
- **Better error messages**: More specific remediation steps for different heading hierarchy issues

#### Skip Link Detection
- **Enhanced pattern matching**: Detects skip links using multiple patterns (`skip-link`, `skiplink`, `href="#main"`, `href="#maincontent"`, etc.)
- **Flexible selector support**: Works with various CSS classes and ID patterns commonly used for skip links

#### Accessible Name Detection
- **Image alt text in links**: Links containing images now properly use the image's alt text as the accessible name
- **Better ARIA label handling**: Improved detection of accessible names via `aria-label` and `aria-labelledby`

#### Error Message Formatting
- **Unified output format**: Consistent error and warning formatting with timestamps and context
- **Centralized reporting**: Errors shown first, then warnings, then success messages
- **Removed confusing messages**: Eliminated "passed with warnings" message for clearer output

### Fixed

- **View file detection for `/items/search`**: Fixed issue where routes like `/items/search` (action: `search`, view: `search_result.html.erb`) weren't being detected
- **Partial detection in layouts**: Fixed issue where partials in `layouts/` directory weren't being properly detected
- **Change detection false positives**: Fixed issue where changing one partial was marking too many pages as affected
- **Route parameter handling**: Better handling of routes with `GET|POST` verbs and multiple parameters
- **CSV warnings in test environment**: Suppressed Ruby 3.3+ CSV deprecation warnings in both application and test environments
- **Test result tracking**: Fixed issue where tests were showing "all passed" even when errors were present
- **RSpec hook syntax**: Fixed `NoMethodError` with `RSpec.after(:suite)` by using correct `RSpec.configure` syntax
- **FactoryBot loading**: Fixed `NameError` when FactoryBot is not present in the project

### Improved

- **Test execution speed**: Removed unnecessary `sleep` calls and reduced Capybara wait times
- **Output readability**: Better formatting, emojis, and visual hierarchy in test output
- **Documentation**: Comprehensive updates to README, ARCHITECTURE, and guides
- **Code organization**: Better separation of concerns with `PartialDetection` module
- **Error handling**: More robust error handling throughout the codebase

### Technical Details

- **New module**: `AccessibilityHelper::PartialDetection` for reusable partial detection logic
- **Enhanced `BaseCheck`**: Now includes partial detection methods for better view file identification
- **Cache mechanism**: Module-level `@scanned_pages` hash for efficient page tracking
- **Improved `ChangeDetector`**: Enhanced logic for detecting file changes and their impact on pages
- **Better route recognition**: Uses `Rails.application.routes.recognize_path` for accurate route-to-view mapping

### Migration Notes

- **No breaking changes**: This release is fully backward compatible
- **Automatic upgrades**: Existing installations will automatically benefit from improved view detection
- **Generator updates**: Re-running `rails generate rails_a11y:install` will update to the latest spec template
- **CSV gem**: If using Ruby 3.3+, explicitly add `gem 'csv'` to your Gemfile (generator handles this)

## [1.4.3] - 2025-11-19

### Added
- Comprehensive driver setup documentation for Capybara and Selenium WebDriver
- Explicit `selenium-webdriver` gem requirement in all Gemfile examples
- Chrome/Chromium installation instructions for macOS, Linux, and Windows
- Troubleshooting section covering common errors including `DriverFinder` issues
- Version compatibility table with recommended and minimum versions
- Rails 8 specific setup notes and requirements

### Improved
- Enhanced getting started guides with complete driver configuration examples
- Better documentation for Rails 8 compatibility and `driven_by` method usage
- Clearer instructions for resolving `uninitialized constant Selenium::WebDriver::DriverFinder` errors
- More comprehensive setup instructions covering all required dependencies

## [1.4.2] - 2025-11-18

### Added
- Procfile.dev documentation for continuous accessibility checking during development
- Instructions for running accessibility checks automatically every 30 seconds via `bin/dev`
- Updated getting started guides with Procfile setup examples
- Enhanced README with continuous testing workflow documentation

### Improved
- Better developer experience with continuous accessibility feedback during development
- Clearer documentation on multiple ways to run accessibility checks (manual vs continuous)
- Improved onboarding with step-by-step Procfile setup instructions

## [1.4.1] - 2025-11-18

### Changed
- Updated RubyGems homepage to point to GitHub Pages documentation site for better discoverability
- Users can now easily access comprehensive documentation directly from the RubyGems gem page

## [1.4.0] - 2025-11-18

### Changed
- Updated documentation examples to use clearer language ("runs accessibility checks" instead of "passes accessibility checks")
- Improved test descriptions to accurately reflect that tests will fail if accessibility issues are found
- Enhanced comments in examples to clarify when success messages appear

### Improved
- Better clarity in documentation about when accessibility checks pass vs fail
- More accurate test descriptions that don't imply tests will pass when they may fail
- Improved user understanding of accessibility check behavior

## [1.3.0] - 2025-11-18

### Added
- CLI reports now use ErrorMessageBuilder for detailed, formatted error messages
- CLI reports include comprehensive remediation steps, element details, and WCAG references
- Better empty alt text detection (checks both Capybara attributes and JavaScript getAttribute)
- Improved server port detection with better error handling and timeout management

### Changed
- CLI default profile changed to `:development` for faster checks (color contrast disabled by default)
- Improved server wait logic with longer retry times (up to 20 seconds) and better port re-detection
- Report generation now skips when no URLs are checked (cleaner output when server isn't ready)
- Port detection now prioritizes common Rails ports (3000, 3001, 4000, 5000) and excludes problematic ports

### Fixed
- Fixed logger accessor compatibility issue - logger access is now optional to work with older gem versions
- Fixed CLI connection issues by improving port detection and server readiness checks
- Fixed CLI showing empty reports when server isn't ready - now shows informative message instead
- Improved error handling for connection timeouts and connection refused errors
- Better handling of interrupt signals during server wait operations

### Improved
- CLI error messages are now more detailed and actionable with specific remediation steps
- Server detection is more reliable with improved timeout handling and error recovery
- Better user experience when running in Procfile.dev with automatic retries

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

[1.5.0]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.5.0
[1.4.3]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.4.3
[1.4.2]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.4.2
[1.4.1]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.4.1
[1.4.0]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.4.0
[1.3.0]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.3.0
[1.2.0]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.2.0
[1.1.6]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.1.6
[1.1.5]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.1.5
[1.1.4]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.1.4
[1.1.3]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.1.3
[1.1.0]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.1.0
[1.0.0]: https://github.com/rayraycodes/rails-accessibility-testing/releases/tag/v1.0.0

