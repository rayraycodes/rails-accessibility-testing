---
layout: default
title: Architecture
---

# Architecture Overview

Simple visual guide to how Rails Accessibility Testing works.

---

## How It Works

The gem integrates into your Rails app and automatically checks accessibility:

```mermaid
graph TB
    subgraph "Your Rails App"
        Tests[System Tests]
        Views[View Files]
    end
    
    subgraph "Rails A11y Gem"
        Engine[Rule Engine]
        Checks[11 Accessibility Checks]
        Scanner[Static File Scanner]
    end
    
    Tests --> Engine
    Views --> Scanner
    Scanner --> Engine
    Engine --> Checks
    Checks --> Reports[Error Reports]
    
    style Engine fill:#4ecdc4
    style Scanner fill:#feca57
    style Checks fill:#45b7d1
```

---

## Two Ways to Scan

### 1. System Tests (Browser-Based)

Runs automatically when you visit pages in tests:

```mermaid
sequenceDiagram
    participant Test as Your Test
    participant Gem as Rails A11y
    participant Browser as Browser
    participant Checks as 11 Checks
    
    Test->>Browser: visit('/page')
    Browser->>Gem: Page loaded
    Gem->>Checks: Run all checks
    Checks->>Gem: Report violations
    Gem->>Test: Show errors with file locations
```

### 2. Static Scanner (File-Based) ⭐ Recommended

Scans ERB files directly - faster, no browser needed:

```mermaid
graph LR
    A[ERB File] --> B[Extract HTML]
    B --> C[Run Checks]
    C --> D[Show Errors]
    
    style A fill:#ff6b6b
    style C fill:#4ecdc4
    style D fill:#ffeaa7
```

**Benefits:**
- ⚡ 10-100x faster than browser-based
- 📍 Shows exact file and line number
- 🔄 Runs continuously in `bin/dev`
- 🎯 Only scans changed files

---

## Static Scanner Flow

How the static scanner works:

```mermaid
graph TB
    Start[Start Scanner] --> Load[Load Config]
    Load --> Check{Files Changed?}
    Check -->|Yes| Scan[Scan Changed Files]
    Check -->|No| Wait[Wait for Changes]
    Scan --> Extract[Extract HTML from ERB]
    Extract --> Run[Run 11 Checks]
    Run --> Show[Show Errors]
    Show --> Wait
    Wait --> Check
    
    style Start fill:#ff6b6b
    style Scan fill:#4ecdc4
    style Show fill:#ffeaa7
```

---

## What Gets Checked

The gem runs **11 accessibility checks**:

1. Form Labels
2. Image Alt Text
3. Interactive Elements
4. Heading Hierarchy
5. Keyboard Accessibility
6. ARIA Landmarks
7. Form Errors
8. Table Structure
9. Duplicate IDs
10. Skip Links
11. Color Contrast

All checks are WCAG 2.1 AA aligned.

---

## Configuration

Everything is configured via `config/accessibility.yml`:

```yaml
# Enable/disable checks
checks:
  form_labels: true
  image_alt_text: true
  color_contrast: false  # Disabled by default (slow)

# Static scanner settings
static_scanner:
  scan_changed_only: true    # Only scan changed files
  full_scan_on_startup: true  # Full scan on startup
  check_interval: 3          # Seconds between checks

# Summary settings
summary:
  ignore_warnings: false  # Hide warnings, only show errors
```

---

## Key Components

### Static Scanner Components

1. **StaticFileScanner** - Main orchestrator
2. **FileChangeTracker** - Tracks which files changed
3. **ErbExtractor** - Converts ERB to HTML
4. **StaticPageAdapter** - Makes HTML work with checks
5. **LineNumberFinder** - Maps errors to line numbers
6. **ViolationConverter** - Formats results

All components work together to scan files and report errors with exact locations.

---

## Summary

✅ **Automatic** - Runs automatically in tests  
✅ **Fast** - Static scanner is 10-100x faster  
✅ **Precise** - Shows exact file and line number  
✅ **Configurable** - Control via YAML  
✅ **Simple** - Just add gem and run tests  

**Version**: 1.5.5
