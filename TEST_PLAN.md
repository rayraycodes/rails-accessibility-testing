# Rails Accessibility Testing - Comprehensive Test Plan

## Overview

This test suite ensures the gem is reliable, accurate, and low-noise in real-world Rails applications. Tests are organized by WCAG principles and gem-specific functionality.

## Test Strategy

### 1. Unit Tests
- **Check Classes**: Each of the 11 check classes has dedicated unit tests
- **BaseCheck**: Tests for common functionality (element context, page context, violation creation)
- **RuleEngine**: Tests for check coordination, configuration application, error handling
- **ViolationCollector**: Tests for violation aggregation and statistics
- **Configuration**: Tests for YAML loading, profile merging, default values
- **ErrorMessageBuilder**: Tests for error message formatting and remediation generation

### 2. Integration Tests
- **RSpec Integration**: Tests automatic hook setup, skip_a11y metadata, page detection
- **Minitest Integration**: Tests helper inclusion, automatic checks, teardown behavior
- **RuleEngine Integration**: Tests full check execution against real HTML pages
- **CLI Integration**: Tests command parsing, URL checking, report generation

### 3. System/Feature Tests
- **Capybara-based**: Tests that visit actual HTML pages and verify checks work correctly
- **False Positive Prevention**: Tests that valid Rails patterns (form helpers, link_to, etc.) are not flagged
- **Edge Cases**: Tests for hidden elements, dynamic content, complex forms

### 4. WCAG Coverage

#### Perceivable (1.x)

**1.1.1 Non-text Content (Level A)**
- ✅ Image alt text check
  - Positive: Missing alt attribute detected
  - Positive: Empty alt="" is valid (decorative images)
  - Negative: Valid alt text not flagged
  - Edge: Images in hidden containers
  - Edge: SVG images with title/desc

**1.3.1 Info and Relationships (Level A)**
- ✅ Form labels check
  - Positive: Missing label detected
  - Positive: aria-label accepted
  - Positive: aria-labelledby accepted
  - Negative: Valid label associations not flagged
  - Edge: Wrapped labels (label > input)
  - Edge: Radio/checkbox groups with fieldset/legend
- ✅ Heading hierarchy check
  - Positive: Missing H1 detected
  - Positive: Skipped levels detected (h1 → h3)
  - Negative: Valid hierarchy not flagged
  - Edge: Multiple H1s (warning, not error)
  - Edge: Headings in hidden sections
- ✅ Table structure check
  - Positive: Missing headers detected
  - Negative: Valid tables with th not flagged
  - Edge: Tables with caption
  - Edge: Complex tables with thead/tbody

**1.4.3 Contrast (Minimum) (Level AA)**
- ⚠️ Color contrast check (stub for future implementation)
  - Placeholder tests for when implemented
  - Tests for contrast calculation logic

#### Operable (2.x)

**2.1.1 Keyboard (Level A)**
- ✅ Keyboard accessibility check
  - Positive: Modal without focusable elements detected
  - Negative: Valid modals with buttons not flagged
  - Edge: Focus traps in modals
  - Edge: Hidden focusable elements

**2.4.1 Bypass Blocks (Level A)**
- ✅ Skip links check
  - Positive: Missing skip link (warning)
  - Negative: Valid skip links not flagged
  - Edge: Skip link targeting non-existent ID

**2.4.4 Link Purpose (Level A)**
- ✅ Interactive elements check
  - Positive: Link without accessible name detected
  - Positive: Button without accessible name detected
  - Positive: aria-label accepted
  - Positive: aria-labelledby accepted
  - Negative: Valid links/buttons not flagged
  - Edge: Icon-only buttons with aria-label
  - Edge: Links with visually hidden text

#### Understandable (3.x)

**3.3.1 Error Identification (Level A)**
- ✅ Form errors check
  - Positive: Error not associated with input detected
  - Positive: aria-describedby accepted
  - Negative: Valid error associations not flagged
  - Edge: Multiple error messages
  - Edge: Dynamic error injection

#### Robust (4.x)

**4.1.1 Parsing (Level A)**
- ✅ Duplicate IDs check
  - Positive: Duplicate IDs detected
  - Negative: Unique IDs not flagged
  - Edge: IDs in different contexts (should still be unique)

**4.1.2 Name, Role, Value (Level A)**
- ✅ Interactive elements check (covered above)
- ✅ ARIA landmarks check
  - Positive: Missing main landmark detected
  - Negative: Valid landmarks not flagged
  - Edge: Multiple main landmarks (should warn)
  - Edge: Native HTML5 landmarks (main, nav, etc.)

## Test Organization

```
spec/
├── rails_accessibility_testing/
│   ├── checks/
│   │   ├── image_alt_text_check_spec.rb
│   │   ├── form_labels_check_spec.rb
│   │   ├── interactive_elements_check_spec.rb
│   │   ├── heading_hierarchy_check_spec.rb
│   │   ├── keyboard_accessibility_check_spec.rb
│   │   ├── aria_landmarks_check_spec.rb
│   │   ├── form_errors_check_spec.rb
│   │   ├── table_structure_check_spec.rb
│   │   ├── duplicate_ids_check_spec.rb
│   │   ├── skip_links_check_spec.rb
│   │   └── color_contrast_check_spec.rb
│   ├── engine/
│   │   ├── rule_engine_spec.rb
│   │   ├── violation_collector_spec.rb
│   │   └── violation_spec.rb
│   ├── config/
│   │   └── yaml_loader_spec.rb
│   ├── error_message_builder_spec.rb
│   ├── configuration_spec.rb
│   ├── rspec_integration_spec.rb
│   ├── integration/
│   │   └── minitest_integration_spec.rb
│   └── cli/
│       └── command_spec.rb
├── support/
│   ├── capybara_setup.rb
│   ├── html_fixtures.rb
│   └── shared_examples/
│       ├── accessibility_check_shared_examples.rb
│       └── false_positive_prevention_shared_examples.rb
└── spec_helper.rb
```

## Test Coverage Goals

- **Unit Tests**: 100% coverage of check logic, configuration, error building
- **Integration Tests**: All integration points (RSpec, Minitest, CLI) tested
- **False Positive Prevention**: All common Rails patterns verified as not flagged
- **Edge Cases**: Hidden elements, dynamic content, complex forms, edge HTML patterns

## Quality Gates

1. **Accuracy**: All WCAG violations must be detected
2. **Low Noise**: Valid Rails patterns must not be flagged
3. **Performance**: Tests complete in reasonable time (< 30s for full suite)
4. **Maintainability**: Tests are clear, well-documented, and easy to extend
5. **Regression Prevention**: Previously fixed bugs have dedicated tests

## Future Test Areas (Stubs)

- **Timing Controls (2.2.x)**: Auto-playing media, time limits
- **Motion (2.3.x)**: Animation preferences
- **Language (3.1.1)**: Page language detection
- **Focus Management**: Focus order, visible focus indicators
- **Live Regions**: ARIA live regions for dynamic content

## Notes

- Tests use Capybara with headless Chrome for realistic browser behavior
- HTML fixtures are kept minimal and focused on specific test cases
- Integration tests may require a dummy Rails app (optional, can stub)
- Performance tests verify checks don't timeout on large pages
- Error handling tests ensure one check failure doesn't break others

