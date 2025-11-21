# Rails Accessibility Testing - Comprehensive Manual

**Version:** 1.5.5  
**Date:** November 2025  
**Author:** Regan Maharjan  

---

## 📖 Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Getting Started](#2-getting-started)
   - [Prerequisites](#prerequisites)
   - [Installation](#installation)
   - [Configuration](#configuration)
3. [Core Features](#3-core-features)
   - [Automated Checks](#automated-checks)
   - [Live Accessibility Scanner](#live-accessibility-scanner)
   - [Static File Scanner](#static-file-scanner)
4. [Developer Guide](#4-developer-guide)
   - [Writing Accessible Views](#writing-accessible-views)
   - [System Specs](#system-specs)
   - [Handling Violations](#handling-violations)
5. [Collaboration Guide](#5-collaboration-guide)
   - [For Designers](#for-designers)
   - [For Content Authors](#for-content-authors)
6. [Architecture Reference](#6-architecture-reference)
7. [Contributing](#7-contributing)

---

## 1. Executive Summary

Rails Accessibility Testing is the "RSpec + RuboCop" of accessibility for Rails. It fills a critical gap in the Rails testing ecosystem by ensuring applications are accessible to everyone, compliant with WCAG 2.1 AA standards.

Unlike manual audits that happen late in development, this tool integrates directly into your test suite and development workflow, catching violations as you code. It provides:

- **11+ Comprehensive Checks**: Covering forms, images, headings, contrast, and more.
- **Zero Configuration**: Smart defaults that work out of the box.
- **Precise Feedback**: Pinpoints exact files and lines of code.
- **Dual Scanning**: Both browser-based (system specs) and static analysis (ERB scanning).

---

## 2. Getting Started

### Prerequisites
- Ruby 3.0+
- Rails 6.0+
- RSpec Rails (recommended) or Minitest
- Chrome/Chromium browser (for system specs)

### Installation

Add to your `Gemfile`:

```ruby
group :development, :test do
  gem 'rails_accessibility_testing'
  gem 'rspec-rails', '~> 6.0'
  gem 'axe-core-capybara'
  gem 'capybara'
  gem 'selenium-webdriver'
end
```

Run installation:

```bash
bundle install
rails generate rails_a11y:install
```

This creates:
- `config/initializers/rails_a11y.rb`
- `config/accessibility.yml`
- `spec/system/all_pages_accessibility_spec.rb`

### Configuration

Configure checks in `config/accessibility.yml`. You can enable/disable specific checks or adjust severity.

```yaml
wcag_level: AA
checks:
  color_contrast: false # Expensive check, disable in dev if needed
  heading: true
```

---

## 3. Core Features

### Automated Checks
The gem runs 11 key checks automatically:
1. **Form Labels**: Inputs must have labels.
2. **Image Alt Text**: Images must have descriptions.
3. **Interactive Elements**: Links/buttons need names.
4. **Heading Hierarchy**: Logical H1-H6 structure.
5. **Keyboard Accessibility**: No keyboard traps.
6. **ARIA Landmarks**: Proper page structure.
7. **Form Errors**: Errors linked to fields.
8. **Table Structure**: Headers required.
9. **Duplicate IDs**: Unique IDs required.
10. **Skip Links**: Navigation bypass links.
11. **Color Contrast**: Text readability.

### Live Accessibility Scanner
Scans pages as you browse in development.

Add to `Procfile.dev`:
```yaml
a11y: bundle exec a11y_static_scanner
```

### Static File Scanner
Scans ERB templates directly without a browser for instant feedback.
Run it manually:
```bash
bundle exec a11y_static_scanner
```

---

## 4. Developer Guide

### Writing Accessible Views

**Semantic HTML is key.**
- Use `<button>` for actions, `<a>` for navigation.
- Use proper heading levels (`<h1>` -> `<h6>`).
- Ensure forms have `<label>` elements linked via `for` attribute.

**Example (Good):**
```erb
<%= form_with model: @user do |f| %>
  <%= f.label :email, "Email Address" %>
  <%= f.email_field :email %>
<% end %>
```

**Example (Bad):**
```erb
<!-- Missing Label -->
<%= f.email_field :email, placeholder: "Email" %>
```

### System Specs
Recommended way to test. Checks run automatically on page visits.

```ruby
RSpec.describe 'Home Page', type: :system do
  it 'is accessible' do
    visit root_path
    expect(page).to have_content('Welcome')
    # Checks run automatically here!
  end
end
```

---

## 5. Collaboration Guide

Accessibility is a team effort.

### For Designers
- **Contrast**: Ensure text meets 4.5:1 contrast ratio.
- **Focus States**: Design visible focus indicators for all interactive elements.
- **Touch Targets**: Minimum 44x44px for mobile.

### For Content Authors
- **Alt Text**: Describe the *meaning* of the image, not just the appearance.
  - *Bad*: "image.jpg"
  - *Good*: "Chart showing Q3 sales growth of 15%"
- **Link Text**: Avoid "Click here". Use descriptive text like "Read our Privacy Policy".

---

## 6. Architecture Reference

The gem is built on a modular architecture:
- **Rule Engine**: Orchestrates checks.
- **Violation Collector**: Aggregates issues.
- **View Detector**: Maps URLs back to source files.
- **Static Scanner**: fast ERB parsing using Nokogiri.

See `ARCHITECTURE.md` in the repo for deep dive diagrams.

---

## 7. Contributing

We welcome contributions!
1. Fork the repo.
2. Create a feature branch.
3. Run tests (`bundle exec rspec`).
4. Submit a Pull Request.

Please adhere to the Code of Conduct.

---

*Generated for project documentation purposes.*

