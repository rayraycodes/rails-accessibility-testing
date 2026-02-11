# Best Practices for Rails Accessibility Testing

This guide documents recommended practices for configuring and using Rails Accessibility Testing in your Rails application, based on real-world usage and production experience.

## Configuration Best Practices

### 1. Disable by Default for CI/CD Safety

**Recommended:** Set `accessibility_enabled: false` in `config/accessibility.yml`

```yaml
# config/accessibility.yml
accessibility_enabled: false
```

**Why?**
- Prevents accessibility test failures from blocking your entire CI/CD pipeline
- Allows other RSpec tests to pass even if accessibility tests fail
- Gives you control over when to run accessibility checks
- Enables manual testing: `rspec spec/accessibility/all_pages_accessibility_spec.rb`

**When to enable:**
- Set to `true` when you want accessibility tests to run automatically
- Use manual invocation for focused accessibility testing
- Enable in CI only when you're ready to enforce accessibility compliance

**Example:**
```yaml
# Default: false 
#   (Set to false to allow other RSpec tests to pass in GitHub Actions CI even if accessibility tests fail.
#    When true, any failing accessibility tests will cause the entire CI pipeline to fail.)
# Set to true to run accessibility checks manually: rspec spec/accessibility/all_pages_accessibility_spec.rb
accessibility_enabled: false
```

### 2. Production Safety Guard

**Recommended:** Wrap configuration in conditional check

```ruby
# config/initializers/rails_a11y.rb
if defined?(RailsAccessibilityTesting)
  RailsAccessibilityTesting.configure do |config|
    config.auto_run_checks = false
    # ... other config
  end
end
```

**Why?**
- Prevents errors if gem is not available in production
- Allows gem to be excluded from production bundle
- Safe deployment even if gem configuration is present

### 3. Manual Control Over Automatic Checks

**Recommended:** Set `auto_run_checks = false` in initializer

```ruby
config.auto_run_checks = false
```

**Why?**
- Gives developers explicit control over when checks run
- Prevents unexpected test failures during development
- Allows focused accessibility testing when needed
- Use `check_comprehensive_accessibility` explicitly in specs when desired

**Alternative:** Enable per-environment
```ruby
config.auto_run_checks = Rails.env.development? || Rails.env.test?
```

### 4. Use Accessibility-Specific RSpec Type

**Recommended:** Use `type: :accessibility` for accessibility specs

```ruby
RSpec.describe 'All Pages Accessibility', type: :accessibility do
  # ...
end
```

**Why?**
- Proper RSpec integration with accessibility helpers
- Better test organization and filtering
- Clearer intent in test files

### 5. Improved Error Formatting

**Recommended:** Use unified formatting method for better output

The generator now creates a `format_issues_by_file` helper method that:
- Groups errors and warnings by file
- Shows errors first, then warnings
- Provides better structure and readability
- Uses proper test assertions (`expect(errors).to be_empty`)

## CI/CD Integration Best Practices

### GitHub Actions

**Recommended approach:**

1. **Keep accessibility disabled by default:**
   ```yaml
   # config/accessibility.yml
   accessibility_enabled: false
   ```

2. **Run accessibility tests separately:**
   ```yaml
   # .github/workflows/accessibility.yml
   - name: Run accessibility tests
     run: |
       bundle exec rspec spec/accessibility/all_pages_accessibility_spec.rb
     continue-on-error: true  # Don't block PRs initially
   ```

3. **Gradually enforce:**
   - Start with `continue-on-error: true` to see results
   - Fix existing issues
   - Then set `continue-on-error: false` to enforce

### Profile-Based Configuration

Use different profiles for different environments:

```yaml
# config/accessibility.yml
development:
  checks:
    color_contrast: false  # Skip expensive checks in dev

test:
  checks:
    # Use global settings

ci:
  checks:
    color_contrast: true   # Full checks in CI
```

Then set profile in CI:
```bash
RAILS_A11Y_PROFILE=ci bundle exec rspec spec/accessibility/
```

## Development Workflow Best Practices

### 1. Use Static Scanner During Development

Add to `Procfile.dev`:
```procfile
a11y: bundle exec a11y_static_scanner
```

**Benefits:**
- Fast feedback without browser
- Only scans changed files
- Continuous monitoring as you code
- Precise file locations and line numbers

### 2. Manual Testing When Needed

Run accessibility tests explicitly:
```bash
# Test all pages
rspec spec/accessibility/all_pages_accessibility_spec.rb

# Test specific page
rspec spec/system/home_page_accessibility_spec.rb
```

### 3. Fix Issues Incrementally

1. **Start with critical issues** - Focus on errors first
2. **Fix by file** - Address all issues in one file at a time
3. **Test incrementally** - Run tests after each fix
4. **Document exceptions** - Use `ignored_rules` with reasons

## Configuration File Best Practices

### Documentation URLs

Always use the correct documentation URL:
```yaml
# See https://rayraycodes.github.io/rails-accessibility-testing/ for full documentation.
```

### Comprehensive Comments

Add detailed comments explaining decisions:
```yaml
# Global enable/disable flag for all accessibility checks
# Set to false to completely disable all accessibility checks (manual and automatic)
# When false, check_comprehensive_accessibility and automatic checks will be skipped
# Default: false 
#   (Set to false to allow other RSpec tests to pass in GitHub Actions CI even if accessibility tests fail.
#    When true, any failing accessibility tests will cause the entire CI pipeline to fail.)
# Set to true to run accessibility checks manually: rspec spec/accessibility/all_pages_accessibility_spec.rb
accessibility_enabled: false
```

## Test Spec Best Practices

### 1. Use Proper Test Assertions

**Recommended:**
```ruby
if errors.any? || warnings.any?
  expect(errors).to be_empty, format_static_errors(errors, warnings)
else
  puts "\n✅ #{view_file}: No errors found"
end
```

**Why?**
- Cleaner test output
- Proper RSpec integration
- Better error messages
- Only fails on errors, not warnings

### 2. Improved Error Formatting

Use unified formatting method:
```ruby
def format_issues_by_file(issues_by_file, output, issue_type)
  issues_by_file.each_with_index do |(file_path, file_issues), file_index|
    output << "" if file_index > 0
    output << "📝 #{file_path} (#{file_issues.length} #{issue_type}#{'s' if file_issues.length != 1})"
    # ... format each issue
  end
end
```

**Benefits:**
- Consistent formatting
- Better readability
- Easier to maintain

## Summary

These best practices are based on real-world production usage and help ensure:

1. **CI/CD Safety** - Accessibility tests don't block other tests
2. **Production Safety** - No errors if gem isn't available
3. **Developer Control** - Explicit control over when checks run
4. **Better UX** - Improved error formatting and test output
5. **Incremental Adoption** - Easy to start and gradually enforce

## Credits

These best practices were refined based on contributions from:
- **Margarita Barvinok** - Production configuration improvements
- Real-world usage in Rails applications
- Community feedback and testing

---

**Questions?** See the main [README](../README.md) or open an issue.
