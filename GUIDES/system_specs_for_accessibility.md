# Using System Specs for Accessibility Testing

System specs are the **recommended and most reliable** way to run accessibility checks in your Rails application. This guide shows you how to set up continuous accessibility testing using RSpec system specs.

## Why System Specs?

✅ **More Reliable** - Runs in the same test environment as your other specs  
✅ **Faster** - No need to wait for external server processes  
✅ **Better Integration** - Works seamlessly with your existing test suite  
✅ **Automatic** - Checks run automatically after each `visit` in system specs  
✅ **Clear Feedback** - Detailed error messages with file locations and fix instructions  

## Quick Setup

### 1. Use the Generated Specs

The generator creates `spec/system/all_pages_accessibility_spec.rb` which automatically tests all GET routes in your application with **smart change detection**. This spec only tests pages when their related files (views, controllers, helpers) have changed, making it fast and focused.

You can also create custom system specs for specific pages. Name them with `_accessibility_spec.rb` suffix for clarity:

```ruby
# spec/system/my_page_accessibility_spec.rb
require 'rails_helper'

RSpec.describe 'My Page Accessibility', type: :system do
  it 'loads the page and runs comprehensive accessibility checks' do
    visit root_path
    
    # Run comprehensive accessibility checks
    # This will fail the test if any accessibility issues are found
    check_comprehensive_accessibility
    # ✅ If all checks pass, you'll see: "All comprehensive accessibility checks passed! (11 checks)"
  end
end
```

### 2. Automatic Checks

The gem automatically runs comprehensive accessibility checks after each `visit` in system specs. You don't need to call `check_comprehensive_accessibility` manually unless you want to run checks at a specific point in your test.

### 3. Continuous Testing with Static Scanner (Recommended)

The generator automatically adds a static accessibility scanner to your `Procfile.dev`:

```procfile
web: bin/rails server
css: bin/rails dartsass:watch
a11y: bundle exec a11y_static_scanner
```

This provides fast, continuous feedback by scanning view files directly without browser rendering. The scanner:
- Scans all files on startup
- Only re-scans files that have changed
- Shows errors with exact file locations and line numbers
- Watches for file changes continuously

See the [Getting Started Guide](getting_started.md) for more details on static scanner configuration.

This will run your accessibility specs every 30 seconds while you develop. The `all_pages_accessibility_spec.rb` uses smart change detection to only test pages when their related files change, making it fast and focused.

## Example Specs

### Basic Page Check

```ruby
# spec/system/my_page_accessibility_spec.rb
require 'rails_helper'

RSpec.describe 'My Page Accessibility', type: :system do
  it 'runs accessibility checks on the home page' do
    visit root_path
    # ✅ Comprehensive accessibility checks run automatically after this test!
    # The test will fail if any accessibility issues are found
  end
end
```

### Multiple Pages

```ruby
# spec/system/pages_accessibility_spec.rb
require 'rails_helper'

RSpec.describe 'Pages Accessibility', type: :system do
  it 'runs accessibility checks on home page' do
    visit root_path
    # Checks run automatically - test fails if issues found
  end

  it 'runs accessibility checks on about page' do
    visit about_path
    # Checks run automatically - test fails if issues found
  end

  it 'runs accessibility checks on contact page' do
    visit contact_path
    # Checks run automatically - test fails if issues found
  end
end
```

### With User Authentication

```ruby
# spec/system/dashboard_accessibility_spec.rb
require 'rails_helper'

RSpec.describe 'Dashboard Accessibility', type: :system do
  before do
    user = FactoryBot.create(:user)
    sign_in user
  end

  it 'runs accessibility checks on dashboard' do
    visit dashboard_path
    # ✅ Comprehensive accessibility checks run automatically after authentication!
    # The test will fail if any accessibility issues are found
  end
end
```

### Skip Checks for Specific Tests

```ruby
it 'does something without accessibility checks', skip_a11y: true do
  visit some_path
  # Accessibility checks won't run for this test
end
```

## What Gets Checked

The gem automatically runs **11 comprehensive accessibility checks**:

1. ✅ **Form Labels** - All form inputs have associated labels
2. ✅ **Image Alt Text** - All images have descriptive alt attributes
3. ✅ **Interactive Elements** - Buttons, links have accessible names
4. ✅ **Heading Hierarchy** - Proper h1-h6 structure
5. ✅ **Keyboard Accessibility** - All interactive elements keyboard accessible
6. ✅ **ARIA Landmarks** - Proper use of ARIA landmark roles
7. ✅ **Form Error Associations** - Errors linked to form fields
8. ✅ **Table Structure** - Tables have proper headers
9. ✅ **Duplicate IDs** - No duplicate ID attributes
10. ✅ **Skip Links** - Skip navigation links present
11. ✅ **Color Contrast** - Text meets contrast requirements (optional, disabled by default)

## Success Messages

When all checks pass, you'll see:

```
✅ All comprehensive accessibility checks passed! (11 checks)
```

## Error Messages

When issues are found, you get detailed, actionable errors:

```
======================================================================
❌ ACCESSIBILITY ERROR: Page missing H1 heading
======================================================================

📄 Page Being Tested:
   URL: http://127.0.0.1:54384/
   Path: /
   📝 Likely View File: app/views/home/about.html.erb

📍 Element Details:
   Tag: <page>
   ID: (none)
   Classes: (none)
   Visible text: Page has no H1 heading

🔧 HOW TO FIX:
   Add an <h1> heading to your page:

   <h1>Main Page Title</h1>

   Or in Rails ERB:
   <h1><%= @page_title || 'Default Title' %></h1>

   💡 Best Practice: Every page should have exactly one <h1>.
      It should describe the main purpose of the page.

📖 WCAG Reference: https://www.w3.org/WAI/WCAG21/Understanding/
======================================================================
```

## Running Specs

### Run All Accessibility Specs

```bash
bundle exec rspec spec/system/*_accessibility_spec.rb
```

### Run Specific Spec

```bash
bundle exec rspec spec/system/all_pages_accessibility_spec.rb
```

### Run with Documentation Format

```bash
bundle exec rspec spec/system/*_accessibility_spec.rb --format documentation
```

## Continuous Integration

Add to your CI configuration:

```yaml
# .github/workflows/ci.yml
- name: Run Accessibility Tests
  run: bundle exec rspec spec/system/*_accessibility_spec.rb
```

## Best Practices

1. **Name your specs clearly** - Use `_accessibility_spec.rb` suffix
2. **Test critical paths** - Focus on user-facing pages
3. **Keep specs simple** - One page per spec is often enough
4. **Use Procfile.dev** - For continuous testing during development
5. **Run in CI** - Catch issues before they reach production

## Troubleshooting

### Checks Not Running

Make sure:
- Your spec has `type: :system`
- You call `visit` in your test
- The gem is properly configured in `spec/rails_helper.rb`

### Success Message Not Showing

The success message appears when all checks pass. If you don't see it, there may be silent failures. Check your RSpec output for any exceptions.

### Slow Tests

Disable color contrast checking in development:

```yaml
# config/accessibility.yml
development:
  checks:
    color_contrast: false
```

## Next Steps

- See [Getting Started Guide](getting_started.md) for initial setup
- See [Continuous Integration Guide](continuous_integration.md) for CI/CD setup
- See [Writing Accessible Views](writing_accessible_views_in_rails.md) for best practices

