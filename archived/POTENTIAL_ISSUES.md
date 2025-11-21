# Potential GitHub Issues

This document lists potential issues and enhancement areas that could be added to GitHub Issues.

## 🔍 How to Check Existing Issues

1. **Visit GitHub Issues**: https://github.com/rayraycodes/rails-accessibility-testing/issues
2. **Search existing issues** before creating a new one to avoid duplicates
3. **Use issue templates** when creating new issues:
   - Bug Report template: `.github/ISSUE_TEMPLATE/bug_report.md`

## 📋 Potential Issues/Enhancements

### 🧪 Testing & Coverage

1. **Integration Tests Missing**
   - RSpec and Minitest auto-hook behavior needs integration tests
   - CLI functionality needs test coverage
   - Current tests use `rack_test` driver, need browser-based tests

2. **Performance Tests**
   - Large page handling (1000+ elements)
   - Timeout behavior under slow conditions
   - Memory usage with many pages

3. **Regression Tests**
   - Tests for previously fixed bugs to prevent regressions
   - Snapshot tests for error message format stability

### 🚀 Feature Enhancements

4. **Custom Rules Support**
   - Allow teams to define custom accessibility checks
   - Plugin system for custom rules

5. **Visual Regression Testing**
   - Screenshot comparison for visual accessibility issues
   - Color contrast visual verification

6. **Performance Monitoring**
   - Track check performance over time
   - Identify slow checks
   - Performance metrics dashboard

7. **IDE Integration**
   - VS Code extension/plugin
   - IntelliJ/RubyMine plugin
   - Real-time feedback in editor

8. **CI/CD Templates**
   - Pre-built GitHub Actions workflows
   - CircleCI configuration templates
   - GitLab CI templates

9. **Parallel Check Execution**
   - Run checks in parallel for faster results
   - Currently checks run sequentially

10. **Incremental Reports**
    - Show only new issues since last run
    - Diff reports between versions

### 🐛 Known Limitations

11. **False Positive Prevention**
    - Better handling of Rails helper patterns (`form_with`, `link_to`, etc.)
    - Some Rails helpers generate accessible HTML but checks might flag them

12. **Dynamic Content**
    - Limited support for JavaScript-rendered content
    - Need better handling of SPA (Single Page Applications)

13. **Authentication/Authorization**
    - Pages requiring login are skipped
    - Could add support for test authentication helpers

14. **Multi-language Support**
    - Error messages are English-only
    - Could add i18n support

### 🔧 Technical Improvements

15. **Dummy Rails App for Testing**
    - More realistic integration testing
    - Test against actual Rails app structure

16. **Code Coverage Reports**
    - Add code coverage metrics
    - Track test coverage over time

17. **CI Integration**
    - Automated test running in CI
    - GitHub Actions workflow

18. **Documentation**
    - More examples for edge cases
    - Video tutorials
    - More real-world use cases

### 🎯 Accessibility Checks

19. **Additional WCAG Checks**
    - More WCAG 2.1 AA criteria
    - WCAG 2.2 support
    - AAA level checks (optional)

20. **ARIA Pattern Validation**
    - Validate ARIA patterns (combobox, dialog, etc.)
    - Check ARIA attribute combinations

21. **Keyboard Navigation Testing**
    - More comprehensive keyboard navigation checks
    - Tab order validation
    - Focus trap detection

### 📊 Reporting & Analytics

22. **Historical Tracking**
    - Track accessibility issues over time
    - Trend analysis
    - Progress reports

23. **Export Formats**
    - JSON export for CI/CD integration
    - CSV export for spreadsheet analysis
    - HTML reports with screenshots

24. **Dashboard/Web UI**
    - Web-based dashboard for viewing reports
    - Historical data visualization
    - Team collaboration features

## 🎫 Creating a New Issue

When creating a new issue:

1. **Check if it already exists**: Search GitHub issues first
2. **Use the template**: Choose the appropriate template (Bug Report, Feature Request)
3. **Be specific**: Include:
   - Clear description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - Environment details (Ruby, Rails, gem versions)
   - Code examples if applicable
4. **Add labels**: Use appropriate labels (bug, enhancement, documentation, etc.)
5. **Link related issues**: Reference related issues or PRs

## 📝 Issue Template Example

```markdown
## Description
[Clear description of the issue/feature]

## Steps to Reproduce (for bugs)
1. Step one
2. Step two
3. See error

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- Ruby version: [e.g., 3.1.0]
- Rails version: [e.g., 7.1.0]
- Gem version: [e.g., 1.5.0]
- OS: [e.g., macOS 14.0]

## Additional Context
[Any other relevant information]
```

## 🔗 Related Documentation

- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical architecture
- [TEST_SUITE_SUMMARY.md](TEST_SUITE_SUMMARY.md) - Test coverage details

