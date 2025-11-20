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
├── Static Scanning System (NEW in 1.5.3)
│   ├── StaticFileScanner    # Main orchestrator for file-based scanning
│   ├── FileChangeTracker   # Tracks file modification times
│   ├── ErbExtractor        # Converts ERB templates to HTML
│   ├── StaticPageAdapter   # Makes Nokogiri look like Capybara
│   ├── LineNumberFinder    # Maps HTML elements to ERB line numbers
│   └── ViolationConverter  # Formats violations with line numbers
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
        
        subgraph "Static Scanning"
            StaticScanner[Static File Scanner]
            FileTracker[File Change Tracker]
            ErbExtractor[ERB Extractor]
            StaticAdapter[Static Page Adapter]
            LineFinder[Line Number Finder]
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
    
            StaticScanner --> FileTracker[FileChangeTracker]
            StaticScanner --> ErbExtractor
            ErbExtractor --> StaticAdapter[StaticPageAdapter]
            StaticAdapter --> RuleEngine
            StaticScanner --> LineFinder[LineNumberFinder]
            StaticScanner --> ViolationConverter[ViolationConverter]
            ViolationConverter --> LineFinder
            ViolationConverter --> ErrorBuilder
    
    style Entry fill:#ff6b6b
    style RuleEngine fill:#4ecdc4
    style Checks fill:#45b7d1
    style ViewDetector fill:#96ceb4
    style ErrorBuilder fill:#ffeaa7
    style Cache fill:#a29bfe
    style StaticScanner fill:#feca57
    style FileTracker fill:#ff9ff3
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

### Static Scanning System (NEW in 1.5.3+)

The static scanning system allows scanning view files directly without browser rendering, providing fast feedback during development. It's the recommended approach for continuous development testing via `bin/dev`.

#### Architecture Overview

The static scanner uses a modular, pipeline-based architecture:

```
ERB Template → ErbExtractor → HTML → StaticPageAdapter → RuleEngine → Checks → Violations → ViolationConverter → Errors/Warnings
```

#### Components

1. **StaticFileScanner** - Main orchestrator
   - Reads ERB template files from `app/views/**/*.html.erb`
   - Coordinates the entire scanning pipeline
   - Loads configuration via `YamlLoader`
   - Creates `RuleEngine` instance with config
   - Returns structured hash: `{ errors: [...], warnings: [...] }`

2. **FileChangeTracker** - Change detection for static files
   - **State File**: `tmp/.rails_a11y_scanned_files.json`
   - **Purpose**: Tracks file modification times (mtime) to detect changes
   - **Methods**:
     - `load_state`: Reads JSON state file, returns hash of `{ file_path => mtime }`
     - `changed_files(files)`: Compares current mtimes with stored state, returns changed/new files
     - `update_state(files)`: Updates state file with current mtimes (atomic write)
     - `clear_state`: Clears state file (forces full rescan)
   - **Atomic Writes**: Uses temp file + `mv` to prevent partial writes

3. **ErbExtractor** - ERB to HTML conversion
   - **Purpose**: Converts Rails helpers to HTML placeholders for static analysis
   - **Supported Helpers**:
     - Form: `select_tag`, `text_field_tag`, `password_field_tag`, `email_field_tag`, `text_area_tag`, `check_box_tag`, `radio_button_tag`, `label_tag`, `form_with`, `form_for`
     - Images: `image_tag`
     - Links: `link_to` (with/without blocks, with/without text)
     - Buttons: `button_tag`, `f.submit`, `button`
   - **Process**:
     1. Convert Rails helpers to HTML (preserves attributes: id, name, src, alt, href)
     2. Remove ERB tags (`<% ... %>`, `<%= ... %>`)
     3. Clean up whitespace
   - **Limitations**: Cannot execute Ruby code, only converts helpers to placeholders

4. **StaticPageAdapter** - Capybara compatibility layer
   - **Purpose**: Makes Nokogiri documents look like Capybara pages
   - **Key Methods**:
     - `all(selector, visible: true)`: Returns array of `StaticElementAdapter` instances
     - `has_css?(selector, wait: true)`: Checks if selector exists
     - `current_url`, `current_path`: Returns `nil` (not applicable)
   - **StaticElementAdapter**: Wraps Nokogiri elements to look like Capybara elements
     - `tag_name`, `[]`, `text`, `visible?`, `all(selector)`, `find(:xpath, '..')`
   - **Benefit**: Allows reuse of existing checks without modification

5. **LineNumberFinder** - Precise error location
   - **Purpose**: Maps HTML elements back to original ERB line numbers
   - **Matching Strategy** (in order of specificity):
     1. Match by `id` attribute (most specific)
     2. Match by `src` attribute (for images)
     3. Match by `href` attribute (for links)
     4. Match by `type` attribute (for inputs)
     5. Match by tag name (fallback)
   - **Returns**: 1-indexed line number or `nil` if not found

6. **ViolationConverter** - Result formatting
   - **Purpose**: Converts raw `Violation` objects to structured errors/warnings
   - **Process**:
     1. Iterates through violations from `RuleEngine`
     2. Uses `LineNumberFinder` to find line numbers
     3. Categorizes as error or warning (based on `warning?` method)
     4. Filters warnings if `ignore_warnings: true` in config
     5. Returns `{ errors: [...], warnings: [...] }`
   - **Warning Detection**: 
     - Skip links → warnings (best practice, not required)
     - ARIA landmarks → warnings (best practice, not always required)
     - Everything else → errors

#### Complete Static Scanner Flow

```mermaid
graph TB
    Start[a11y_static_scanner Startup] --> LoadConfig[Load accessibility.yml]
    LoadConfig --> LoadState[FileChangeTracker.load_state]
    LoadState --> GetFiles[Get all view files<br/>app/views/**/*.html.erb]
    GetFiles --> Decision{scan_changed_only?}
    
    Decision -->|false| ScanAll[Scan ALL files]
    Decision -->|true| CheckStartup{full_scan_on_startup?}
    
    CheckStartup -->|true| ScanAll
    CheckStartup -->|false| CheckChanged[FileChangeTracker.changed_files]
    
    CheckChanged --> ChangedEmpty{Changed files empty?}
    ChangedEmpty -->|yes| WatchLoop[Enter watch loop<br/>sleep check_interval]
    ChangedEmpty -->|no| ScanChanged[Scan changed files only]
    
    ScanAll --> ScanFile[For each file:<br/>StaticFileScanner.scan]
    ScanChanged --> ScanFile
    
    ScanFile --> ReadFile[Read ERB file content]
    ReadFile --> Extract[ErbExtractor.extract_html]
    Extract --> Parse[Nokogiri.parse HTML]
    Parse --> Adapter[StaticPageAdapter.new]
    Adapter --> LoadConfig2[YamlLoader.load profile: :test]
    LoadConfig2 --> Engine[RuleEngine.new config: config]
    Engine --> RunChecks[Run all 11 enabled checks]
    RunChecks --> Collect[Collect violations]
    Collect --> Convert[ViolationConverter.convert]
    Convert --> FindLines[LineNumberFinder.find_line_number]
    FindLines --> Filter{ignore_warnings?}
    Filter -->|true| RemoveWarnings[Remove warnings]
    Filter -->|false| KeepAll[Keep errors + warnings]
    RemoveWarnings --> Format[Format errors/warnings]
    KeepAll --> Format
    Format --> UpdateState[FileChangeTracker.update_state]
    UpdateState --> Output[Display results]
    
    Output --> Continuous{scan_changed_only?}
    Continuous -->|true| WatchLoop
    Continuous -->|false| Exit[Exit]
    
    WatchLoop --> Sleep[sleep check_interval]
    Sleep --> CheckAgain[FileChangeTracker.changed_files]
    CheckAgain --> HasChanges{Has changes?}
    HasChanges -->|yes| ScanChanged
    HasChanges -->|no| Sleep
    
    style Start fill:#ff6b6b
    style ScanFile fill:#4ecdc4
    style Extract fill:#ff9ff3
    style Adapter fill:#48dbfb
    style Engine fill:#feca57
    style FindLines fill:#ff6b6b
    style Format fill:#ffeaa7
```

#### File Selection Logic

The static scanner uses a sophisticated file selection algorithm based on configuration flags:

```mermaid
graph TB
    Start[Scanner Startup] --> Config[Load Config]
    Config --> Flags{Read Flags}
    Flags --> ScanChanged[scan_changed_only]
    Flags --> FullStartup[full_scan_on_startup]
    
    ScanChanged -->|false| AlwaysScan[Scan ALL files every time]
    ScanChanged -->|true| CheckStartup{full_scan_on_startup?}
    
    CheckStartup -->|true| StartupScan[Scan ALL files on startup]
    CheckStartup -->|false| ChangedOnly[Only scan changed files]
    
    StartupScan --> AfterStartup[After startup scan completes]
    ChangedOnly --> CheckEmpty{Any changed files?}
    
    CheckEmpty -->|no| WatchMode[Enter watch mode<br/>Check every check_interval seconds]
    CheckEmpty -->|yes| ScanChangedFiles[Scan changed files]
    
    AfterStartup --> WatchMode
    ScanChangedFiles --> WatchMode
    
    WatchMode --> Sleep[sleep check_interval]
    Sleep --> CheckChanges[FileChangeTracker.changed_files]
    CheckChanges --> HasChanges{Has changes?}
    HasChanges -->|yes| ScanChangedFiles
    HasChanges -->|no| Sleep
    
    AlwaysScan --> Done[Exit after scan]
    
    style StartupScan fill:#55efc4
    style ScanChangedFiles fill:#fdcb6e
    style WatchMode fill:#a29bfe
```

#### Configuration Flags Reference

All configuration is done via `config/accessibility.yml`:

##### Static Scanner Configuration (`static_scanner`)

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `scan_changed_only` | Boolean | `true` | Only scan files that have changed since last scan. When `false`, scans all files every time. |
| `check_interval` | Integer | `3` | Seconds between file change checks when running continuously. Only used when `scan_changed_only: true`. |
| `full_scan_on_startup` | Boolean | `true` | Force full scan of all files on startup. When `false`, only scans changed files from the start. |

**Flag Interaction Matrix:**

| `scan_changed_only` | `full_scan_on_startup` | Behavior |
|---------------------|------------------------|---------|
| `false` | `true`/`false` | Scan all files every time, exit after scan |
| `true` | `true` | Scan all files on startup, then watch for changes |
| `true` | `false` | Only scan changed files, watch for changes |

##### Summary Configuration (`summary`)

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `show_summary` | Boolean | `true` | Show summary at end of test suite (RSpec only) |
| `errors_only` | Boolean | `false` | Show only errors in summary, hide warnings (RSpec only) |
| `show_fixes` | Boolean | `true` | Show fix suggestions in error messages |
| `ignore_warnings` | Boolean | `false` | **Filter out warnings completely** - only show errors. Used by both static scanner and RSpec. |

**Warning Filtering:**
- `ignore_warnings: true` → Warnings are filtered out at `ViolationConverter` level
- `errors_only: true` → Warnings are hidden in summary but still collected (RSpec only)

##### Check Configuration (`checks`)

| Check | Default | Description |
|-------|---------|-------------|
| `form_labels` | `true` | Form inputs have associated labels |
| `image_alt_text` | `true` | Images have alt attributes |
| `interactive_elements` | `true` | Interactive elements have accessible names |
| `heading` | `true` | Proper heading hierarchy |
| `keyboard_accessibility` | `true` | Elements are keyboard accessible |
| `aria_landmarks` | `true` | Proper ARIA landmark roles |
| `form_errors` | `true` | Form errors linked to fields |
| `table_structure` | `true` | Tables have proper headers |
| `duplicate_ids` | `true` | No duplicate IDs |
| `skip_links` | `true` | Skip navigation links present |
| `color_contrast` | `false` | Text meets contrast requirements (expensive) |

##### Profile-Specific Configuration

Configuration supports profiles (`development`, `test`, `ci`) with deep merging:

```yaml
# Base config
wcag_level: AA
checks:
  color_contrast: false

# Profile-specific (deep merged)
development:
  checks:
    color_contrast: false  # Overrides base
  static_scanner:
    check_interval: 5  # Overrides base

ci:
  checks:
    color_contrast: true  # Overrides base
```

**Merging Rules:**
- Base config + Profile config = Merged config
- Checks are merged (profile overrides base)
- Summary config is merged (profile overrides base)
- Static scanner config is merged (profile overrides base)
- `ignored_rules` are concatenated and deduplicated

#### Data Flow: ERB to Error Report

```mermaid
sequenceDiagram
    participant Scanner as StaticFileScanner
    participant File as ERB File
    participant Extractor as ErbExtractor
    participant Nokogiri as Nokogiri Parser
    participant Adapter as StaticPageAdapter
    participant Config as YamlLoader
    participant Engine as RuleEngine
    participant Check as Check (e.g., FormLabelsCheck)
    participant Collector as ViolationCollector
    participant Converter as ViolationConverter
    participant Finder as LineNumberFinder
    participant Output as CLI Output
    
    Scanner->>File: Read file content
    File-->>Scanner: ERB template string
    
    Scanner->>Extractor: extract_html(content)
    Extractor->>Extractor: Convert Rails helpers to HTML
    Extractor->>Extractor: Remove ERB tags
    Extractor-->>Scanner: HTML string
    
    Scanner->>Nokogiri: Parse HTML
    Nokogiri-->>Scanner: Nokogiri::Document
    
    Scanner->>Adapter: new(html, view_file: path)
    Adapter-->>Scanner: StaticPageAdapter instance
    
    Scanner->>Config: load(profile: :test)
    Config-->>Scanner: Config hash with checks, summary, static_scanner
    
    Scanner->>Engine: new(config: config)
    Engine-->>Scanner: RuleEngine instance
    
    Scanner->>Engine: check(static_page, context: { view_file })
    
    loop For each enabled check
        Engine->>Check: new(page: static_page, context: context)
        Check->>Adapter: all('input[type="text"]')
        Adapter-->>Check: Array of StaticElementAdapter
        Check->>Check: Validate WCAG rules
        Check-->>Engine: Array of Violations
        Engine->>Collector: add(violations)
    end
    
    Engine-->>Scanner: Array of Violation objects
    
    Scanner->>Finder: new(file_content)
    Finder-->>Scanner: LineNumberFinder instance
    
    Scanner->>Converter: convert(violations, view_file, finder, config)
    
    loop For each violation
        Converter->>Finder: find_line_number(element_context)
        Finder-->>Converter: Line number (1-indexed)
        Converter->>Converter: Categorize as error/warning
        Converter->>Converter: Filter warnings if ignore_warnings: true
    end
    
    Converter-->>Scanner: { errors: [...], warnings: [...] }
    
    Scanner->>Output: Display formatted errors
    Output->>Output: Show file path, line number, error type
```

#### Integration Points

1. **RuleEngine Integration**
   - Static scanner uses the same `RuleEngine` as system specs
   - All 11 checks work identically for both static and dynamic scanning
   - Configuration (`checks`, `ignored_rules`) applies to both

2. **Configuration Integration**
   - `YamlLoader` loads config with profile support
   - Static scanner uses `profile: :test` (can be changed)
   - Summary config (`ignore_warnings`) applies to both static scanner and RSpec

3. **File Change Tracking**
   - State file: `tmp/.rails_a11y_scanned_files.json`
   - Format: `{ "app/views/pages/home.html.erb": 1234567890.123 }`
   - Atomic writes prevent corruption
   - Automatically cleaned up (removes deleted files)

#### Benefits

- **Fast**: No browser needed - scans ERB templates directly (~10-100x faster than browser-based)
- **Precise**: Reports exact file locations and line numbers
- **Efficient**: Only scans changed files using modification time tracking
- **Continuous**: Runs continuously, watching for file changes
- **Reusable**: Leverages existing RuleEngine and all 11 checks
- **Configurable**: Full control via YAML with profile support

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
│   ├── static_file_scanner.rb     # Static file scanner orchestrator
│   ├── file_change_tracker.rb     # Tracks file modification times
│   ├── erb_extractor.rb           # Converts ERB to HTML
│   ├── static_page_adapter.rb     # Nokogiri → Capybara adapter
│   ├── line_number_finder.rb      # Maps elements to line numbers
│   ├── violation_converter.rb     # Formats violations with line numbers
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
├── a11y_live_scanner            # Live scanner tool (browser-based)
└── a11y_static_scanner          # Static file scanner (NEW in 1.5.0+)

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

## Version 1.5.3+ Highlights

### New Components

1. **PartialDetection Module**: Reusable partial detection logic
2. **Page Scanning Cache**: Module-level cache for scanned pages
3. **Enhanced ChangeDetector**: Asset change detection and smart partial impact analysis
4. **Improved View File Detection**: Fuzzy matching and controller directory scanning
5. **Rails Server Safe Wrapper**: Prevents Foreman from terminating processes
6. **Static Scanning System**: File-based scanning without browser (NEW in 1.5.3+)
   - **StaticFileScanner**: Main orchestrator for static file scanning pipeline
   - **FileChangeTracker**: Tracks file modification times in `tmp/.rails_a11y_scanned_files.json`
   - **ErbExtractor**: Converts ERB templates to HTML (15+ Rails helpers supported)
   - **StaticPageAdapter**: Makes Nokogiri documents compatible with existing checks
   - **LineNumberFinder**: Maps HTML elements to ERB line numbers (1-indexed)
   - **ViolationConverter**: Formats violations with precise file locations, respects `ignore_warnings`

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
5. **Static File Scanning**: Fast file-based scanning without browser overhead (~10-100x faster)
6. **File Change Tracking**: Only scans modified files using modification time tracking (`FileChangeTracker`)
7. **Continuous Monitoring**: Watches for file changes and re-scans automatically (configurable via `check_interval`)
8. **Configuration Flags**: Comprehensive YAML configuration with profile support (`scan_changed_only`, `full_scan_on_startup`, `ignore_warnings`, etc.)

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

**Architecture Version**: 1.5.5  
**Last Updated**: 2025-11-20
