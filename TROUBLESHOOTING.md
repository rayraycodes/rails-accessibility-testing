# Troubleshooting Guide

## Generator Not Found Error

If you see:
```
Could not find generator 'rails_a11y:install'. (Rails::Command::CorrectableNameError)
```

### Solution Steps:

1. **Clear Rails cache** (if using Spring):
   ```bash
   bundle exec spring stop
   ```

2. **Restart your terminal** - Sometimes Rails caches generator lists

3. **Verify the gem is loaded**:
   ```bash
   bundle show rails_accessibility_testing
   ```
   Should show: `/Users/imregan/workprojects/rails-accessibility-testing`

4. **Check generator is discoverable**:
   ```bash
   bundle exec rails generate --help | grep a11y
   ```
   Should show: `rails_a11y:install`

5. **Try running the generator with bundle exec**:
   ```bash
   bundle exec rails generate rails_a11y:install
   ```

6. **If using a local path gem** (like `path: '../rails-accessibility-testing'`):
   - Make sure the path is correct in your Gemfile
   - Run `bundle install` again
   - Restart your terminal

7. **Clear tmp cache**:
   ```bash
   rm -rf tmp/cache
   ```

8. **Verify the generator file exists**:
   ```bash
   ls -la lib/generators/rails_a11y/install/install_generator.rb
   ```

### Common Causes:

- **Spring caching** - Rails Spring preloader caches generators
- **Terminal session** - Old terminal sessions might have stale cache
- **Gem path issues** - Local path gems need bundle install after changes
- **File permissions** - Generator files need to be readable

### Quick Fix:

```bash
# Stop Spring (if running)
bundle exec spring stop

# Clear cache
rm -rf tmp/cache

# Reinstall bundle (if using local path)
bundle install

# Try generator again
bundle exec rails generate rails_a11y:install
```

