# Rails Accessibility Testing Gem - Architecture Overview

## Project Identity

### Gem Name Options

After careful consideration, we've selected:

**Final Name: `rails_accessibility_testing`**

**Note:** The gem uses `rails_a11y` as a short alias for the generator command and CLI tool, but the official gem name is `rails_accessibility_testing`.

**Alternative names considered:**
1. `rails_accessibility_testing` - **SELECTED** - Clear and descriptive
2. `rails_a11y` - Short alias used for CLI and generator
3. `a11y_rails` - Alternative short form
4. `accessible_rails` - Descriptive but longer

### Tagline

**"The RSpec + RuboCop of accessibility for Rails. Catch WCAG violations before they reach production."**

### Positioning Statement

Rails Accessibility Testing fills a critical gap in the Rails testing ecosystem. While RSpec ensures code works and RuboCop ensures code style, Rails Accessibility Testing ensures applications are accessible to everyone. Unlike manual accessibility audits that happen late in development, Rails Accessibility Testing integrates directly into your test suite, catching violations as you code. It's opinionated enough to guide teams new to accessibility, yet configurable enough for experienced teams. By making accessibility testing as natural as unit testing, Rails Accessibility Testing helps teams build accessible applications from day one, not as an afterthought.

---

## Architecture Overview

### Core Principles

1. **DevX First**: Every feature prioritizes developer experience
2. **Accessibility at Core**: WCAG 2.1 AA compliance is the foundation
3. **Rails Native**: Feels like a natural part of Rails, not a bolt-on
4. **Progressive Enhancement**: Works with zero config, scales with configuration

### Component Architecture

```
rails_a11y/
├── Core Engine
│   ├── Rule Engine          # Evaluates accessibility rules
│   ├── Check Definitions    # WCAG-aligned check implementations
│   └── Violation Collector  # Aggregates and formats violations
│
├── Rails Integration
│   ├── Railtie             # Rails initialization hooks
│   ├── RSpec Integration    # RSpec helpers and matchers
│   ├── Minitest Integration # Minitest helpers
│   └── System Test Helpers  # Capybara integration
│
├── Configuration
│   ├── YAML Config Loader   # Loads config/accessibility.yml
│   ├── Profile Manager      # Dev/test/CI profiles
│   └── Rule Overrides       # Ignore rules with comments
│
├── CLI
│   ├── Command Runner       # Main CLI entry point
│   ├── URL Scanner          # Scans URLs/routes
│   └── Report Generator     # Human-readable + JSON reports
│
├── Generators
│   └── Install Generator    # Rails generator for setup
│
└── Documentation
    ├── Guides/              # Practical guides
    ├── API Docs (YARD)      # Generated documentation
    └── Doc Site             # Static documentation site
```

### Data Flow

```
Test Execution
    ↓
System Test Helper (RSpec/Minitest)
    ↓
Rule Engine
    ↓
Check Definitions (11+ checks)
    ↓
Violation Collector
    ↓
Error Message Builder
    ↓
Test Failure / CLI Report
```

### Rule Engine Design

The rule engine is the heart of the gem. It:

1. **Loads Configuration**: Reads `config/accessibility.yml` with profile support**
2. **Applies Rule Overrides**: Respects ignored rules with comments
3. **Executes Checks**: Runs enabled checks in order
4. **Collects Violations**: Aggregates all violations before reporting
5. **Formats Output**: Creates actionable error messages

### Check Definition Structure

Each check is a self-contained class that:

- Implements a standard interface
- Returns violations with context
- Includes WCAG references
- Provides remediation suggestions
- Can be enabled/disabled via config

---

## Key Design Decisions

### 1. YAML Configuration

**Why YAML?** 
- Human-readable and comment-friendly
- Easy to version control
- Familiar to Rails developers
- Supports profiles (dev/test/CI)

### 2. Rule-Based Architecture

**Why separate rules?**
- Easy to enable/disable specific checks
- Allows teams to gradually adopt stricter rules
- Makes it easy to add custom rules later
- Clear separation of concerns

### 3. Violation Collection vs Immediate Failure

**Why collect then fail?**
- Shows all issues at once (better DX)
- Allows prioritization
- More efficient than stopping at first error
- Better for CI/CD reports

### 4. View File Detection

**Why detect view files?**
- Points developers to exact file to fix
- Works with partials and layouts
- Reduces debugging time
- Makes errors actionable

### 5. Dual Test Framework Support

**Why both RSpec and Minitest?**
- Rails teams use both
- Reduces friction for adoption
- Shared core logic, different interfaces
- Better market fit

---

## File Structure

```
lib/
├── rails_a11y.rb                    # Main entry point
├── rails_a11y/
│   ├── version.rb
│   ├── configuration.rb             # Config management
│   ├── railtie.rb                   # Rails integration
│   │
│   ├── engine/
│   │   ├── rule_engine.rb           # Core rule evaluator
│   │   ├── violation_collector.rb   # Aggregates violations
│   │   └── check_context.rb         # Context for checks
│   │
│   ├── checks/
│   │   ├── base_check.rb            # Base class for all checks
│   │   ├── form_labels_check.rb
│   │   ├── image_alt_text_check.rb
│   │   ├── interactive_elements_check.rb
│   │   ├── heading_hierarchy_check.rb
│   │   ├── keyboard_accessibility_check.rb
│   │   ├── aria_landmarks_check.rb
│   │   ├── form_errors_check.rb
│   │   ├── table_structure_check.rb
│   │   ├── duplicate_ids_check.rb
│   │   ├── skip_links_check.rb
│   │   └── color_contrast_check.rb   # New
│   │
│   ├── integration/
│   │   ├── rspec_integration.rb
│   │   ├── minitest_integration.rb
│   │   └── system_test_helper.rb    # Shared Capybara helpers
│   │
│   ├── cli/
│   │   ├── command.rb                # Main CLI command
│   │   ├── url_scanner.rb            # Scans URLs/routes
│   │   └── report_generator.rb       # Generates reports
│   │
│   ├── config/
│   │   ├── yaml_loader.rb            # Loads YAML config
│   │   ├── profile_manager.rb        # Manages profiles
│   │   └── rule_override.rb          # Handles ignored rules
│   │
│   ├── errors/
│   │   ├── error_message_builder.rb  # Formats error messages
│   │   └── violation_formatter.rb   # Formats individual violations
│   │
│   └── utils/
│       ├── view_file_detector.rb     # Detects view files
│       └── wcag_reference.rb         # WCAG reference data
│
├── generators/
│   └── rails_a11y/
│       └── install/
│           ├── generator.rb
│           └── templates/
│               ├── initializer.rb.erb
│               └── accessibility.yml.erb
│
└── tasks/
    └── accessibility.rake            # Rake tasks

exe/
└── rails_a11y                        # CLI executable

GUIDES/
├── getting_started.md
├── continuous_integration.md
├── working_with_designers_and_content_authors.md
└── writing_accessible_views_in_rails.md

docs_site/
├── index.html
├── usage.html
├── configuration.html
├── ci_integration.html
└── contributing.html
```

---

## Extension Points

### Adding Custom Checks

```ruby
module RailsA11y
  module Checks
    class CustomCheck < BaseCheck
      def check
        # Implementation
      end
    end
  end
end
```

### Custom Error Formatters

```ruby
module RailsA11y
  module Errors
    class CustomFormatter < ViolationFormatter
      # Custom formatting logic
    end
  end
end
```

### Profile-Specific Configuration

```yaml
# config/accessibility.yml
development:
  checks:
    color_contrast: false  # Skip in dev for speed

ci:
  checks:
    color_contrast: true   # Full checks in CI
```

---

## Performance Considerations

1. **Lazy Loading**: Checks loaded only when needed
2. **Caching**: View file detection cached
3. **Parallel Execution**: Checks can run in parallel (future)
4. **Selective Execution**: Only run checks for changed files (existing feature)
5. **Configurable Depth**: Expensive checks behind flags

---

## Testing Strategy

1. **Unit Tests**: Each check tested in isolation
2. **Integration Tests**: Full Rails app with RSpec/Minitest
3. **CLI Tests**: Test CLI against real Rails routes
4. **Documentation Tests**: Ensure examples work

---

## Future Enhancements

1. **Custom Rules**: Allow teams to define custom checks
2. **Visual Regression**: Screenshot comparison for visual issues
3. **Performance Monitoring**: Track check performance
4. **IDE Integration**: VS Code/IntelliJ plugins
5. **CI/CD Templates**: Pre-built GitHub Actions, CircleCI configs

