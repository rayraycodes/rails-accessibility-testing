# Getting Started with Rails A11y

Welcome to Rails A11y! This guide will help you get up and running with accessibility testing in your Rails application in just a few minutes.

## What is Rails A11y?

Rails A11y is an accessibility testing gem that automatically checks your Rails views for WCAG 2.1 AA compliance. Think of it as RSpec + RuboCop for accessibility—it catches violations as you code, not after deployment.

## Quick Start (5 Minutes)

### Step 1: Install the Gem

Add to your `Gemfile`:

```ruby
group :development, :test do
  gem 'rails_accessibility_testing'
  gem 'axe-core-capybara', '~> 4.0'
end
```

Then run:

```bash
bundle install
```

### Step 2: Run the Generator

```bash
rails generate rails_a11y:install
```

**Note:** The generator uses the short name `rails_a11y` for convenience. The gem name is `rails_accessibility_testing`.

This creates:
- `config/initializers/rails_a11y.rb` - Configuration
- `config/accessibility.yml` - Check settings
- Updates `spec/rails_helper.rb` (if using RSpec)

### Step 3: Run Your Tests

That's it! Just run your system specs:

```bash
bundle exec rspec spec/system/
```

Accessibility checks run automatically on every system test that visits a page.

## Your First Accessibility Check

Let's see it in action. Create a simple system spec:

```ruby
# spec/system/home_spec.rb
RSpec.describe "Home Page" do
  it "displays the welcome message" do
    visit root_path
    expect(page).to have_content("Welcome")
    # ✅ Accessibility checks run automatically here!
  end
end
```

If there are accessibility issues, you'll see detailed error messages like:

```
======================================================================
❌ ACCESSIBILITY ERROR: Image missing alt attribute
======================================================================

📄 Page Being Tested:
   URL: http://localhost:3000/
   Path: /
   📝 Likely View File: app/views/pages/home.html.erb

📍 Element Details:
   Tag: <img>
   ID: (none)
   Classes: logo
   Src: /assets/logo.png

🔧 HOW TO FIX:
   Choose ONE of these solutions:

   1. Add alt text for informative images:
      <img src="/assets/logo.png" alt="Company Logo">

   2. Use Rails image_tag helper:
      <%= image_tag 'logo.png', alt: 'Company Logo' %>

   💡 Best Practice: All images must have alt attribute.
      Use empty alt="" only for purely decorative images.
```

## Understanding the Checks

Rails A11y runs 11 comprehensive checks:

1. **Form Labels** - All inputs have associated labels
2. **Image Alt Text** - All images have alt attributes
3. **Interactive Elements** - Buttons and links have accessible names
4. **Heading Hierarchy** - Proper h1-h6 structure
5. **Keyboard Accessibility** - All interactive elements are keyboard accessible
6. **ARIA Landmarks** - Proper use of ARIA landmark roles
7. **Form Error Associations** - Errors linked to form fields
8. **Table Structure** - Tables have proper headers
9. **Duplicate IDs** - No duplicate ID attributes
10. **Skip Links** - Skip navigation links present
11. **Color Contrast** - Text meets contrast requirements (optional)

## Configuration

### Basic Configuration

Edit `config/accessibility.yml`:

```yaml
wcag_level: AA

checks:
  form_labels: true
  image_alt_text: true
  # ... other checks
  color_contrast: false  # Disabled by default (expensive)
```

### Profile-Specific Configuration

Different settings for different environments:

```yaml
development:
  checks:
    color_contrast: false  # Skip in dev for speed

ci:
  checks:
    color_contrast: true   # Full checks in CI
```

### Ignoring Rules Temporarily

Sometimes you need to temporarily ignore a rule while fixing issues:

```yaml
ignored_rules:
  - rule: form_labels
    reason: "Legacy form, scheduled for refactor in Q2"
    comment: "Will be fixed in PR #123"
```

**Important:** Always include a reason and plan to fix. This is for temporary exceptions, not permanent workarounds.

## Skipping Checks in Tests

Sometimes you need to skip accessibility checks for specific tests:

```ruby
# RSpec
it "does something", skip_a11y: true do
  # Accessibility checks won't run
end

# Minitest
test "does something", skip_a11y: true do
  # Accessibility checks won't run
end
```

## Next Steps

- **Read the [CI Integration Guide](continuous_integration.md)** to set up automated checks
- **Check out [Writing Accessible Views](writing_accessible_views_in_rails.md)** for best practices
- **See [Working with Designers](working_with_designers_and_content_authors.md)** for team collaboration

## Common Questions

### Q: Do I need to change my existing tests?

**A:** No! Rails A11y works with your existing system tests. Just run them as usual.

### Q: Will this slow down my tests?

**A:** Checks only run when you visit a page in a system test. The checks are fast, and you can disable expensive ones (like color contrast) in development.

### Q: Can I use this with Minitest?

**A:** Yes! See the Minitest integration in the main README.

### Q: What if I disagree with a check?

**A:** You can disable specific checks in `config/accessibility.yml` or ignore specific rules with a reason.

## Getting Help

- **Documentation:** See the main [README](../README.md)
- **Issues:** [GitHub Issues](https://github.com/your-org/rails-a11y/issues)
- **Email:** support@example.com

---

**Ready to make your Rails app accessible?** Run your tests and start fixing issues! 🚀

