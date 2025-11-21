---
layout: default
title: Contributing
---

# Contributing to Rails Accessibility Testing

Thank you for your interest in contributing to Rails Accessibility Testing! This document provides guidelines and instructions for contributing.

## 🤝 Code of Conduct

This project adheres to a code of conduct that all contributors are expected to follow. Please be respectful and constructive in all interactions.

## 🚀 Getting Started

### Prerequisites

- Ruby 3.0+ installed
- Bundler installed
- Git installed
- A GitHub account

### Setting Up Development Environment

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/your-username/rails-accessibility-testing.git
   cd rails-accessibility-testing
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Run tests**
   ```bash
   bundle exec rspec
   ```

## 📝 Making Changes

### Development Workflow

1. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make your changes**
   - Write code
   - Add tests
   - Update documentation

3. **Test your changes**
   ```bash
   bundle exec rspec
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add: descriptive commit message"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Go to the original repository on GitHub
   - Click "New Pull Request"
   - Select your branch
   - Fill out the PR template

## 📋 Commit Message Guidelines

We follow conventional commit message format:

```
type: short description

Longer description if needed

- Bullet point 1
- Bullet point 2
```

**Types:**
- `Add:` - New feature
- `Fix:` - Bug fix
- `Update:` - Update existing feature
- `Refactor:` - Code refactoring
- `Docs:` - Documentation changes
- `Test:` - Test additions/changes
- `Chore:` - Maintenance tasks

**Examples:**
```
Add: support for custom accessibility rules

Allows users to define custom accessibility checks
beyond the default 11 checks.

- Add configuration for custom rules
- Add validation for custom rule format
- Update documentation
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/path/to/spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Writing Tests

- Write tests for all new features
- Ensure existing tests still pass
- Aim for good test coverage
- Test edge cases

## 📚 Documentation

### Updating Documentation

- Update README.md for user-facing changes
- Update CHANGELOG.md for all changes
- Update inline code documentation
- Update setup guides if needed

### Documentation Standards

- Use clear, concise language
- Include code examples
- Explain the "why" not just the "what"
- Keep examples up-to-date

## 🐛 Reporting Bugs

### Before Submitting

1. Check if the bug has already been reported
2. Check if it's fixed in the latest version
3. Try to reproduce the issue

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce:
1. ...
2. ...

**Expected behavior**
What you expected to happen.

**Actual behavior**
What actually happened.

**Environment**
- Ruby version:
- Rails version:
- RSpec version:
- Gem version:

**Additional context**
Any other relevant information.
```

## 💡 Suggesting Features

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
What you want to happen.

**Describe alternatives you've considered**
Other solutions you've thought about.

**Additional context**
Any other relevant information.
```

## 🔍 Code Review Process

1. All PRs require at least one approval
2. Maintainers will review your code
3. Address any feedback
4. Once approved, maintainers will merge

## 📦 Releasing

Only maintainers can release new versions. The process:

1. Update version in `lib/rails_accessibility_testing/version.rb`
2. Update CHANGELOG.md
3. Create git tag
4. Build and push gem to RubyGems

## ❓ Questions?

- Open an issue for questions
- Check existing issues and discussions
- Email: imregan@umich.edu

## 🙏 Thank You!

Your contributions make this project better for everyone. Thank you for taking the time to contribute!
