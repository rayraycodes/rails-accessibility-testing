# Dependencies and Requirements

## Required Gems

### 1. axe-core-capybara

**Purpose:** Automated accessibility testing engine  
**Version:** Latest stable  
**Source:** [RubyGems](https://rubygems.org/gems/axe-core-capybara)

```ruby
gem 'axe-core-capybara'
```

**What it provides:**
- `be_axe_clean` RSpec matcher
- Automated WCAG 2.1 AA compliance checking
- Integration with Capybara system tests

**Installation:**
```bash
bundle add axe-core-capybara --group test
```

---

### 2. RSpec Rails

**Purpose:** Testing framework for Rails  
**Version:** 8.0.0+ recommended  
**Source:** [RubyGems](https://rubygems.org/gems/rspec-rails)

```ruby
gem 'rspec-rails', '~> 8.0.0'
```

**What it provides:**
- System spec infrastructure (`type: :system`)
- Test execution framework
- Matchers and helpers

**Installation:**
```bash
bundle add rspec-rails --group test
```

---

### 3. Capybara

**Purpose:** Browser automation for system tests  
**Version:** 3.40+  
**Source:** [RubyGems](https://rubygems.org/gems/capybara)

```ruby
gem 'capybara', '~> 3.40'
```

**What it provides:**
- Page interaction (`visit`, `click`, `fill_in`, etc.)
- Element finding and querying
- Browser session management

**Installation:**
```bash
bundle add capybara --group test
```

---

### 4. Webdrivers

**Purpose:** Browser driver management  
**Version:** 5.3.0+  
**Source:** [RubyGems](https://rubygems.org/gems/webdrivers)

```ruby
gem 'webdrivers', '= 5.3.0'
```

**What it provides:**
- Automatic ChromeDriver/FirefoxDriver management
- Driver version matching
- No manual driver installation needed

**Installation:**
```bash
bundle add webdrivers --group test
```

---

## System Requirements

### Ruby

**Version:** 3.0+ (3.1+ recommended)  
**Check version:**
```bash
ruby --version
```

### Rails

**Version:** 6.0+ (7.1+ recommended)  
**Check version:**
```bash
rails --version
```

### Browser

**Required:** Chrome/Chromium for headless testing

**macOS:**
```bash
brew install --cask google-chrome
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get install chromium-browser
```

**Linux (Fedora/RHEL):**
```bash
sudo dnf install chromium
```

**Windows:**
Download from [Google Chrome](https://www.google.com/chrome/)

### Git (Optional)

**Purpose:** Change detection  
**Fallback:** File modification times if git unavailable

**Check if installed:**
```bash
git --version
```

---

## Dependency Tree

```
rails_accessibility_testing
├── axe-core-capybara
│   ├── axe-core (JavaScript engine)
│   └── capybara
│       └── selenium-webdriver
│           └── webdrivers
└── rspec-rails
    └── rspec-core
        └── rspec-expectations
```

---

## Installation Order

1. **Install system dependencies** (Chrome, Git)
2. **Add gems to Gemfile**
3. **Run bundle install**
4. **Copy gem files** to `lib/rails_accessibility_testing/`
5. **Require gem** in `rails_helper.rb`

---

## Version Compatibility

| Rails Version | Ruby Version | RSpec Version | Status |
|---------------|--------------|---------------|---------|
| 7.1+ | 3.1+ | 8.0+ | ✅ Recommended |
| 7.0 | 3.0+ | 7.0+ | ✅ Supported |
| 6.1 | 2.7+ | 6.0+ | ✅ Supported |
| 6.0 | 2.6+ | 5.0+ | ⚠️ May work |

---

## Optional Dependencies

### Selenium WebDriver

Usually included automatically with Capybara. If not:

```ruby
gem 'selenium-webdriver'
```

### Factory Bot (for test data)

If you use factories:

```ruby
gem 'factory_bot_rails'
```

### Faker (for test data)

If you generate fake data:

```ruby
gem 'faker'
```

---

## Checking Installation

### Verify Gems Installed

```bash
bundle list | grep -E "(axe|capybara|rspec|webdrivers)"
```

Should show:
- axe-core-capybara
- capybara
- rspec-rails
- webdrivers

### Verify System Requirements

```bash
# Ruby
ruby --version  # Should be 3.0+

# Rails
rails --version  # Should be 6.0+

# Chrome
google-chrome --version  # or chromium --version

# Git (optional)
git --version
```

### Test Installation

```bash
bundle exec rspec spec/system/ --dry-run
```

Should complete without errors.

---

## Troubleshooting Dependencies

### Issue: Bundle install fails

**Solution:**
```bash
# Update bundler
gem update bundler

# Clear bundle cache
bundle clean --force

# Reinstall
bundle install
```

### Issue: Chrome driver not found

**Solution:**
```bash
# Webdrivers should handle this automatically
bundle exec webdrivers install

# Or manually
gem install webdrivers
```

### Issue: Selenium errors

**Solution:**
```bash
# Update selenium-webdriver
bundle update selenium-webdriver

# Reinstall webdrivers
bundle exec webdrivers install
```

### Issue: RSpec not found

**Solution:**
```bash
# Install RSpec
bundle add rspec-rails --group test
rails generate rspec:install
```

---

## Minimal Gemfile Example

```ruby
source 'https://rubygems.org'
ruby '3.1.0'

gem 'rails', '~> 7.1'

group :development, :test do
  gem 'axe-core-capybara'
  gem 'rspec-rails', '~> 8.0.0'
  gem 'capybara', '~> 3.40'
  gem 'webdrivers', '= 5.3.0'
end
```

---

## Production Considerations

**Note:** All dependencies are in `:development, :test` group. They are **NOT** included in production, keeping your production bundle small.

To verify:
```bash
RAILS_ENV=production bundle install
bundle list | grep -E "(axe|capybara|rspec)"
# Should show nothing (or only if explicitly in production group)
```

---

## Summary

**Required:**
- ✅ `axe-core-capybara` gem
- ✅ `rspec-rails` gem
- ✅ `capybara` gem
- ✅ `webdrivers` gem
- ✅ Chrome/Chromium browser
- ✅ Ruby 3.0+
- ✅ Rails 6.0+

**Optional:**
- ⚠️ Git (for change detection, falls back to file timestamps)

**Total bundle size impact:** ~50MB (development/test only)

