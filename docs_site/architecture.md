---
layout: default
title: Architecture
---

# Architecture Overview

This page provides visual diagrams and explanations of how the Rails Accessibility Testing gem works internally.

---

## High-Level System Architecture

The gem integrates seamlessly into your Rails application through multiple layers:

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

---

## Request Flow - How It Works

This sequence diagram shows the complete flow when a test runs:

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

---

## Core Components

### 1. Entry & Integration Layer

The gem integrates with Rails through the Railtie system and automatically hooks into your test framework:

```mermaid
graph LR
    A[Rails App Boots] --> B[Railtie Initializes]
    B --> C[Load Configuration]
    C --> D[Setup Test Hooks]
    D --> E1[RSpec Integration]
    D --> E2[Minitest Integration]
    E1 --> F[Auto-run after each visit]
    E2 --> F
    
    style B fill:#ff6b6b
    style E1 fill:#74b9ff
    style E2 fill:#a29bfe
```

**Key Files:**
- `railtie.rb` - Rails initialization
- `rspec_integration.rb` - RSpec auto-hooks
- `integration/minitest_integration.rb` - Minitest helpers

---

### 2. Core Rule Engine

The rule engine orchestrates all accessibility checks:

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

**Key Features:**
- Profile-based configuration (dev/test/ci)
- Individual check enable/disable
- WCAG 2.1 AA aligned checks
- Violation aggregation

---

### 3. Intelligence Layer (v1.5.0+)

Smart detection and performance optimization:

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
    
    subgraph "Performance System"
        I[Page Visit] --> J{In Cache?}
        J -->|Yes| K[Skip Scan]
        J -->|No| L[Check Changes]
        L --> M{Files Changed?}
        M -->|No| N[Skip Scan]
        M -->|Yes| O[Run Checks]
        O --> P[Add to Cache]
    end
    
    style B fill:#96ceb4
    style J fill:#a29bfe
    style L fill:#fdcb6e
```

**Key Features:**
- **View File Detection**: Finds exact view file from URL
- **Partial Detection**: Maps issues to specific partials
- **Change Detection**: Only tests modified pages
- **Page Cache**: Prevents duplicate scans

---

### 4. Error Reporting System

Generate actionable error messages with precise file locations:

```mermaid
graph TB
    A[Violations Collected] --> B[View File Detector]
    B --> C{Main View Found?}
    C -->|Yes| D[Partial Detector]
    C -->|No| E[URL Only]
    D --> F{In Partial?}
    F -->|Yes| G[Partial Path]
    F -->|No| H[Main View Path]
    
    G --> I[Error Message Builder]
    H --> I
    E --> I
    
    I --> J[Format Message]
    J --> K[Add Fix Suggestions]
    K --> L[Add WCAG Reference]
    L --> M[Add Element Context]
    M --> N[Formatted Error Report]
    
    style B fill:#96ceb4
    style I fill:#ffeaa7
    style N fill:#ff7675
```

**Error Report Includes:**
- Page URL and path
- View file and partial location
- Element details (tag, ID, classes)
- Fix suggestions with code examples
- WCAG 2.1 reference links

---

## Data Flow Example

### Scenario: Detecting an Image Without Alt Text

```mermaid
sequenceDiagram
    participant T as Test
    participant H as Accessibility Helper
    participant C as Page Cache
    participant V as View Detector
    participant R as Rule Engine
    participant I as Image Alt Check
    participant P as Partial Detector
    participant E as Error Builder
    
    T->>H: visit('/products/search')
    H->>C: Check cache for '/products/search'
    C->>H: Not in cache
    H->>V: Detect view file
    V->>V: Route → products#search_results
    V->>V: Find search_results.html.erb
    V->>H: View file located
    H->>R: Run accessibility checks
    R->>I: Execute image alt check
    I->>I: Find all img elements
    I->>I: Check for alt attribute
    I->>I: Found violation: <img src="logo.png">
    I->>P: Detect if in partial
    P->>P: Scan search_results.html.erb
    P->>P: Found render 'shared/header'
    P->>P: Element is in _header.html.erb
    P->>I: Partial location
    I->>R: Report violation with context
    R->>E: Build error message
    E->>E: Format with file paths
    E->>E: Add fix suggestions
    E->>T: Fail test with detailed error
    
    rect rgb(255, 200, 200)
        Note over T: Test fails with error showing:<br/>View: products/search_results.html.erb<br/>Partial: shared/_header.html.erb<br/>Fix: Add alt="Company Logo"
    end
```

---

## Performance Optimization

### Caching & Change Detection Strategy

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

### Impact Analysis

Different file changes have different impacts:

| File Type | Impact | Action |
|-----------|--------|--------|
| Main View | Single page | Test that page only |
| Partial | Multiple pages | Test all pages using partial |
| Controller | Controller routes | Test all routes for controller |
| Helper | Global | Test all pages |
| CSS/JS | Global | Test all pages |
| Layout | Global | Test all pages |

---

## CLI Architecture

Command-line scanning for standalone usage:

```mermaid
graph TB
    A[rails_a11y CLI] --> B[Command Parser]
    B --> C{Command Type?}
    
    C -->|check| D[URL/Path Scanner]
    C -->|generate| E[Generator]
    
    D --> F[Start Rails Server]
    F --> G[Visit URL]
    G --> H[Run Checks]
    H --> I[Generate Report]
    
    I --> J{Format?}
    J -->|human| K[Pretty Terminal Output]
    J -->|json| L[JSON Report File]
    
    style A fill:#6c5ce7
    style I fill:#ffeaa7
```

**Commands:**
- `check` - Scan URLs or routes
- `--format json` - Generate JSON reports
- `--profile ci` - Use specific profile

---

## Extension Points

### Adding Custom Checks

The gem is designed to be extensible:

```ruby
# lib/custom_checks/my_check.rb
module RailsAccessibilityTesting
  module Checks
    class MyCustomCheck < BaseCheck
      def self.rule_name
        :my_custom_check
      end
      
      def check
        violations = []
        # Your check logic here
        # Access: page, context, partial detection
        violations
      end
    end
  end
end
```

---

## Key Design Patterns

### 1. Modular Check System

Each check is self-contained and independently configurable.

### 2. Progressive Enhancement

- **Level 1**: Just add gem → automatic checks
- **Level 2**: Configure via YAML → customize checks  
- **Level 3**: Profiles → environment-specific configs
- **Level 4**: Custom checks → extend functionality

### 3. Smart Caching & Detection

Performance optimizations that work transparently:
- Page cache prevents duplicate scans
- Change detection only tests modified files
- First-run establishes baseline, then incremental

### 4. Developer Experience First

Every feature prioritizes DX:
- Automatic hooks (zero configuration)
- Detailed errors (exact file locations)
- Fix suggestions (code examples)
- Beautiful output (color-coded reports)

---

## Summary

The Rails Accessibility Testing gem provides:

✅ **Seamless Integration** - Auto-hooks into Rails test suite  
✅ **Intelligent Detection** - Finds exact files to fix  
✅ **Performance Optimized** - Smart caching and change detection  
✅ **Developer Friendly** - Detailed errors with fix suggestions  
✅ **Highly Configurable** - Profile-based configuration  
✅ **Extensible** - Easy to add custom checks  
✅ **Production Ready** - Comprehensive WCAG 2.1 AA checks  

---

**For more details, see the [ARCHITECTURE.md](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/ARCHITECTURE.md) file in the repository.**

**Version**: 1.5.0  
**Last Updated**: 2025-11-20
