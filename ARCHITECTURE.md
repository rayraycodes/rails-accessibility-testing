# Rails Accessibility Testing Gem - Architecture Overview

## Project Identity

### Gem Name

**Final Name: `rails_accessibility_testing`**

**Note:** The gem uses `rails_a11y` as a short alias for the generator command and CLI tool, but the official gem name is `rails_accessibility_testing`.

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
5. **Performance Conscious**: Smart caching and change detection for fast feedback

### Component Architecture

```
rails_accessibility_testing/
├── Core Engine
│   ├── Rule Engine          # Evaluates accessibility rules
│   ├── Check Definitions    # WCAG-aligned check implementations (11+ checks)
│   └── Violation Collector  # Aggregates and formats violations
│
├── View Detection System (NEW in 1.5.0)
│   ├── View File Detector   # Finds view files from routes/actions
│   ├── Partial Detection    # Scans view files for rendered partials
│   ├── Route Recognition    # Maps URLs to controller/action pairs
│   └── Fuzzy Matching       # Handles action/view name mismatches
│
├── Performance System (NEW in 1.5.0)
│   ├── Page Scanning Cache  # Prevents duplicate scans
│   ├── Change Detector      # Detects file changes and impact
│   ├── First-Run Logic      # Optimizes initial vs subsequent runs
│   └── Asset Change Detection # Tracks CSS/JS changes
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

#### Visual Architecture Diagram

```mermaid
graph TB
    subgraph "Rails Application"
        App[Your Rails App]
        Tests[System Tests/Specs]
        Views[Views & Partials]
        Routes[Routes & Controllers]
    end
    
    subgraph "Rails Accessibility Testing Gem"
        Entry[Gem Entry Point]
        Railtie[Rails Integration Layer]
        
        subgraph "Test Integration"
            RSpec[RSpec Integration]
            Minitest[Minitest Integration]
            AutoHook[Automatic Test Hooks]
        end
        
        subgraph "Core Engine"
            RuleEngine[Rule Engine]
            Checks[11+ Accessibility Checks]
            Collector[Violation Collector]
        end
        
        subgraph "Intelligence Layer"
            ViewDetector[View File Detector]
            PartialDetector[Partial Detection]
            ChangeDetector[Change Detector]
            Cache[Page Scanning Cache]
        end
        
        subgraph "Configuration"
            YAMLConfig[YAML Config Loader]
            Profiles[Profile Manager]
            RubyConfig[Ruby Configuration]
        end
        
        subgraph "Output & Reporting"
            ErrorBuilder[Error Message Builder]
            CLI[CLI Tool]
            Reports[Reports & Logs]
        end
    end
    
    subgraph "Testing Tools"
        Capybara[Capybara]
        Selenium[Selenium WebDriver]
        AxeCore[axe-core Engine]
    end
    
    Tests --> RSpec
    Tests --> Minitest
    RSpec --> AutoHook
    Minitest --> AutoHook
    App --> Railtie
    Entry --> Railtie
    
    AutoHook --> Cache
    Cache --> ViewDetector
    ViewDetector --> ChangeDetector
    ChangeDetector --> RuleEngine
    RuleEngine --> YAMLConfig
    YAMLConfig --> Profiles
    RuleEngine --> Checks
    Checks --> Capybara
    Capybara --> Selenium
    Checks --> AxeCore
    Checks --> ViewDetector
    ViewDetector --> PartialDetector
    PartialDetector --> Views
    Checks --> Collector
    Collector --> ErrorBuilder
    ErrorBuilder --> Reports
    
    CLI --> RuleEngine
    Routes --> ViewDetector
    
    style Entry fill:#ff6b6b
    style RuleEngine fill:#4ecdc4
    style Checks fill:#45b7d1
    style ViewDetector fill:#96ceb4
    style ErrorBuilder fill:#ffeaa7
    style Cache fill:#a29bfe
```

### Data Flow

```
Test Execution
    ↓
System Test Helper (RSpec/Minitest)
    ↓
Page Scanning Cache Check (NEW in 1.5.0)
    ↓ (if not cached)
Rule Engine
    ↓
Check Definitions (11+ checks)
    ↓
View File Detection (NEW in 1.5.0)
    ├── Route Recognition
    ├── View File Matching
    └── Partial Detection
    ↓
Violation Collector
    ↓
Error Message Builder (with file paths)
    ↓
Test Failure / CLI Report
```

#### Request Flow Sequence Diagram

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Test as Test Suite
    participant Hook as Auto Hooks
    participant Cache as Scan Cache
    participant Detector as View Detector
    participant Change as Change Detector
    participant Engine as Rule Engine
    participant Checks as 11 Check Modules
    participant Capybara as Capybara/Browser
    participant Collector as Violation Collector
    participant Builder as Error Builder
    participant Report as Test Report
    
    Dev->>Test: Run test suite
    Test->>Hook: Execute system test
    Hook->>Test: visit('/some/path')
    Test->>Capybara: Load page
    Capybara->>Test: Page loaded
    
    rect rgb(200, 220, 250)
        Note over Hook,Cache: Performance Optimization
        Hook->>Cache: Check if page scanned
        alt Page already scanned
            Cache->>Hook: Skip (cached)
        else Not in cache
            Cache->>Detector: Continue with scan
        end
    end
    
    rect rgb(220, 250, 220)
        Note over Detector,Change: Smart Detection
        Detector->>Change: Check for file changes
        Change->>Change: Analyze views/partials/assets
        alt No changes detected
            Change->>Hook: Skip scan (no changes)
        else Changes detected
            Change->>Engine: Proceed with checks
        end
    end
    
    rect rgb(250, 220, 220)
        Note over Engine,Checks: Accessibility Checks
        Engine->>Checks: Run enabled checks
        loop For each check (11 total)
            Checks->>Capybara: Query DOM elements
            Capybara->>Checks: Return elements
            Checks->>Checks: Validate WCAG rules
            Checks->>Collector: Report violations
        end
    end
    
    rect rgb(250, 240, 200)
        Note over Collector,Report: Error Reporting
        Collector->>Detector: Map violations to files
        Detector->>Detector: Find view files
        Detector->>Detector: Detect partials
        Detector->>Builder: Pass file locations
        Builder->>Builder: Format error messages
        Builder->>Report: Generate detailed report
    end
    
    alt Violations found
        Report->>Test: Fail with detailed errors
        Test->>Dev: Show actionable errors
    else No violations
        Report->>Test: Pass
        Test->>Dev: ✓ Accessibility checks passed
    end
```

### Rule Engine Design

The rule engine is the heart of the gem. It:

1. **Loads Configuration**: Reads `config/accessibility.yml` with profile support
2. **Applies Rule Overrides**: Respects ignored rules with comments
3. **Executes Checks**: Runs enabled checks in order
4. **Collects Violations**: Aggregates all violations before reporting
5. **Formats Output**: Creates actionable error messages with precise file locations

#### Rule Engine Flow Diagram

```mermaid
graph TB
    A[Rule Engine] --> B[Load Configuration]
    B --> C[Apply Profiles]
    C --> D[Filter Enabled Checks]
    D --> E[Execute Checks in Order]
    
    E --> F1[Form Labels]
    E --> F2[Image Alt Text]
    E --> F3[Interactive Elements]
    E --> F4[Heading Hierarchy]
    E --> F5[Keyboard Access]
    E --> F6[ARIA Landmarks]
    E --> F7[Form Errors]
    E --> F8[Table Structure]
    E --> F9[Duplicate IDs]
    E --> F10[Skip Links]
    E --> F11[Color Contrast]
    
    F1 --> G[Collect Violations]
    F2 --> G
    F3 --> G
    F4 --> G
    F5 --> G
    F6 --> G
    F7 --> G
    F8 --> G
    F9 --> G
    F10 --> G
    F11 --> G
    
    style A fill:#4ecdc4
    style G fill:#ffeaa7
```

### Check Definition Structure

Each check is a self-contained class that:

- Implements a standard interface (`BaseCheck`)
- Returns violations with context
- Includes WCAG references
- Provides remediation suggestions
- Can be enabled/disabled via config
- **NEW in 1.5.0**: Includes partial detection methods for better file location

### View Detection System (NEW in 1.5.0)

The view detection system is a major enhancement that makes error messages much more actionable:

#### View File Detection

1. **Route Recognition**: Uses `Rails.application.routes.recognize_path` to get controller/action
2. **Exact Matching**: First tries exact match (`controller/action.html.erb`)
3. **Fuzzy Matching**: If no exact match, scans controller directory for files containing action name
4. **Preference Logic**: Prefers files starting with action name (e.g., `search_result.html.erb` for `search` action)
5. **Fallback**: If controller has only one view file, uses that

#### Partial Detection

1. **Pattern Scanning**: Scans view file content for `render` statements using multiple regex patterns
2. **Normalization**: Handles various render syntaxes (`render 'partial'`, `render partial: 'partial'`, ERB syntax)
3. **Path Resolution**: Resolves partial paths (handles namespaced partials like `layouts/navbar`)
4. **Multi-Location Search**: Searches in controller directory, `shared/`, and `layouts/`
5. **Element Mapping**: When an accessibility issue is found, determines if it's in a partial

#### Module Structure

```ruby
module AccessibilityHelper
  module PartialDetection
    # Reusable partial detection methods
    def find_partials_in_view_file(view_file)
      # Scans view file for render statements
    end
    
    def find_partial_for_element_in_list(controller, element_context, partial_list)
      # Maps element to specific partial
    end
  end
end
```

#### View Detection Flow Diagram

```mermaid
graph TB
    subgraph "View Detection System"
        A[Page URL] --> B[Route Recognition]
        B --> C{Exact Match?}
        C -->|Yes| D[Found View File]
        C -->|No| E[Fuzzy Matching]
        E --> F[Scan Controller Dir]
        F --> D
        D --> G[Scan for Partials]
        G --> H[Map Elements to Partials]
    end
    
    style B fill:#96ceb4
```

### Performance System (NEW in 1.5.0)

#### Page Scanning Cache

- **Purpose**: Prevents duplicate accessibility scans of the same page
- **Implementation**: Module-level `@scanned_pages` hash
- **Key Strategy**: Uses page path (preferred) or URL as cache key
- **Lifecycle**: Persists for duration of test suite execution
- **API**: `reset_scanned_pages_cache` for manual reset

#### Change Detection

- **Purpose**: Only test pages when relevant files have changed
- **Monitored Files**: Views, controllers, helpers, CSS, JavaScript
- **Impact Analysis**: 
  - Main layouts → affects all pages
  - Specific partials → affects only pages that render them
  - Controllers → affects all routes for that controller
  - Helpers → affects all pages (can be used anywhere)
  - Assets → affects all pages (global impact)

#### First-Run Logic

- **Marker File**: `.rails_a11y_initialized` tracks first run
- **Initial Run**: Tests all pages to establish baseline
- **Subsequent Runs**: Only tests changed files
- **Force Option**: `TEST_ALL_PAGES=true` environment variable

#### Performance Optimization Flow

```mermaid
graph TB
    A[Page Visit] --> B{In Page Cache?}
    B -->|Yes| C[Skip Scan]
    B -->|No| D{First Run?}
    D -->|Yes| E[Scan All Pages]
    D -->|No| F{Files Changed?}
    F -->|No| G[Skip Scan]
    F -->|Yes| H[Smart Scan]
    
    H --> I{Which Files?}
    I -->|View| J[Scan This Page]
    I -->|Partial| K[Scan Pages Using Partial]
    I -->|Helper| L[Scan All Pages]
    I -->|Asset| M[Scan All Pages]
    
    E --> N[Add to Cache]
    J --> N
    K --> N
    L --> N
    M --> N
    
    style B fill:#a29bfe
    style F fill:#fdcb6e
    style N fill:#55efc4
```

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

### 4. View File Detection (Enhanced in 1.5.0)

**Why detect view files?**
- Points developers to exact file to fix
- Works with partials and layouts
- Reduces debugging time
- Makes errors actionable
- **NEW**: Handles action/view name mismatches
- **NEW**: Detects partials automatically

### 5. Page Scanning Cache (NEW in 1.5.0)

**Why cache scanned pages?**
- Prevents duplicate work
- Faster test execution
- Better developer experience
- Reduces unnecessary browser automation

### 6. Smart Change Detection (Enhanced in 1.5.0)

**Why detect changes?**
- Only test what changed (faster feedback)
- Reduces test execution time
- Better CI/CD performance
- **NEW**: Detects asset changes (CSS/JS)
- **NEW**: Smart partial impact analysis

### 7. Dual Test Framework Support

**Why both RSpec and Minitest?**
- Rails teams use both
- Reduces friction for adoption
- Shared core logic, different interfaces
- Better market fit

---

## File Structure

```
lib/
├── rails_accessibility_testing.rb                    # Main entry point
├── rails_accessibility_testing/
│   ├── version.rb
│   ├── configuration.rb             # Config management
│   ├── railtie.rb                   # Rails integration
│   │
│   ├── engine/
│   │   ├── rule_engine.rb           # Core rule evaluator
│   │   ├── violation_collector.rb  # Aggregates violations
│   │   └── violation.rb            # Violation data structure
│   │
│   ├── checks/
│   │   ├── base_check.rb           # Base class for all checks
│   │   │                            # (includes PartialDetection in 1.5.0)
│   │   ├── form_labels_check.rb
│   │   ├── image_alt_text_check.rb
│   │   ├── interactive_elements_check.rb
│   │   ├── heading_check.rb        # Renamed from heading_hierarchy_check
│   │   ├── keyboard_accessibility_check.rb
│   │   ├── aria_landmarks_check.rb
│   │   ├── form_errors_check.rb
│   │   ├── table_structure_check.rb
│   │   ├── duplicate_ids_check.rb
│   │   ├── skip_links_check.rb
│   │   └── color_contrast_check.rb
│   │
│   ├── accessibility_helper.rb      # Main helper module
│   │                                # (includes PartialDetection, page cache)
│   │
│   ├── change_detector.rb          # Smart change detection
│   │                                # (enhanced in 1.5.0 for assets/partials)
│   │
│   ├── integration/
│   │   ├── rspec_integration.rb
│   │   ├── minitest_integration.rb
│   │   └── system_test_helper.rb   # Shared Capybara helpers
│   │
│   ├── cli/
│   │   └── command.rb              # Main CLI command
│   │
│   ├── config/
│   │   └── yaml_loader.rb         # Loads YAML config
│   │
│   ├── error_message_builder.rb   # Formats error messages
│   │                                # (enhanced with partial detection in 1.5.0)
│   │
│   └── middleware/
│       └── page_visit_logger.rb
│
├── generators/
│   └── rails_a11y/
│       └── install/
│           ├── install_generator.rb
│           └── templates/
│               ├── initializer.rb.erb
│               ├── accessibility.yml.erb
│               └── all_pages_accessibility_spec.rb.erb
│               # (enhanced in 1.5.0 with dynamic route discovery)
│
└── tasks/
    └── accessibility.rake

exe/
├── rails_a11y                    # CLI executable
├── rails_server_safe             # Safe server wrapper (NEW in 1.5.0)
└── a11y_live_scanner            # Live scanner tool

GUIDES/
├── getting_started.md
├── continuous_integration.md
├── working_with_designers_and_content_authors.md
└── writing_accessible_views_in_rails.md

docs_site/
├── index.html
├── getting_started.md
├── configuration.md
└── ci_integration.md
```

---

## Extension Points

### Adding Custom Checks

```ruby
module RailsAccessibilityTesting
  module Checks
    class CustomCheck < BaseCheck
      def self.rule_name
        :custom_check
      end
      
      def check
        violations = []
        # Implementation
        # Access to page, context, and partial detection methods
        violations
      end
    end
  end
end
```

### Custom Error Formatters

```ruby
module RailsAccessibilityTesting
  class CustomFormatter
    def format(violation)
      # Custom formatting logic
      # Access to violation.element_context, violation.page_context
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
2. **Caching**: 
   - View file detection cached (implicit)
   - **Page scanning cache** (NEW in 1.5.0): Prevents duplicate scans
3. **Selective Execution**: 
   - Only run checks for changed files (existing feature)
   - **Smart change detection** (enhanced in 1.5.0)
4. **Configurable Depth**: Expensive checks behind flags (color contrast)
5. **Parallel Execution**: Checks can run in parallel (future)

---

## Testing Strategy

1. **Unit Tests**: Each check tested in isolation
2. **Integration Tests**: Full Rails app with RSpec/Minitest
3. **CLI Tests**: Test CLI against real Rails routes
4. **Documentation Tests**: Ensure examples work
5. **Performance Tests**: Verify caching and change detection work correctly

---

## Version 1.5.0 Highlights

### New Components

1. **PartialDetection Module**: Reusable partial detection logic
2. **Page Scanning Cache**: Module-level cache for scanned pages
3. **Enhanced ChangeDetector**: Asset change detection and smart partial impact analysis
4. **Improved View File Detection**: Fuzzy matching and controller directory scanning
5. **Rails Server Safe Wrapper**: Prevents Foreman from terminating processes

### Enhanced Components

1. **BaseCheck**: Now includes PartialDetection for better file location
2. **AccessibilityHelper**: Includes page cache and partial detection
3. **ErrorMessageBuilder**: Shows partial files in error messages
4. **Generator Templates**: Dynamic route discovery and first-run logic
5. **ChangeDetector**: Asset detection and improved partial impact analysis

### Performance Improvements

1. **Page Scanning Cache**: Eliminates duplicate scans
2. **Smart Change Detection**: Only tests affected pages
3. **First-Run Optimization**: Faster initial setup
4. **Reduced Wait Times**: Faster Capybara operations

---

## Future Enhancements

1. **Custom Rules**: Allow teams to define custom checks
2. **Visual Regression**: Screenshot comparison for visual issues
3. **Performance Monitoring**: Track check performance
4. **IDE Integration**: VS Code/IntelliJ plugins
5. **CI/CD Templates**: Pre-built GitHub Actions, CircleCI configs
6. **Parallel Check Execution**: Run checks in parallel for faster results
7. **Incremental Reports**: Show only new issues since last run

---

## Migration Guide

### From 1.4.x to 1.5.0

1. **No breaking changes**: Fully backward compatible
2. **Automatic benefits**: Existing installations get improved view detection automatically
3. **Generator update**: Re-run `rails generate rails_a11y:install` to get latest spec template
4. **CSV gem**: If using Ruby 3.3+, add `gem 'csv'` to Gemfile (generator handles this)
5. **Config update**: `heading_hierarchy` renamed to `heading` in config (backward compatible)

---

**Architecture Version**: 1.5.0  
**Last Updated**: 2025-11-19
