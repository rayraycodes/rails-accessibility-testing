---
layout: default
title: CI Integration
---

# Continuous Integration with Rails Accessibility Testing

This guide shows you how to integrate Rails Accessibility Testing into your CI/CD pipeline to catch accessibility issues before they reach production.

## Why CI Integration?

- **Catch issues early** - Before code is merged
- **Prevent regressions** - Ensure fixes stay fixed
- **Team accountability** - Everyone sees accessibility status
- **Compliance tracking** - Document WCAG compliance

## GitHub Actions

### Basic Setup

Create `.github/workflows/accessibility.yml`:

```yaml
name: Accessibility Tests

on:
  pull_request:
  push:
    branches: [main]

jobs:
  accessibility:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.1
          bundler-cache: true
      
      - name: Install Chrome
        run: |
          sudo apt-get update
          sudo apt-get install -y google-chrome-stable
      
      - name: Setup test database
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost/test
        run: |
          bundle exec rails db:create db:schema:load
      
      - name: Run accessibility tests
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost/test
        run: |
          bundle exec rspec spec/system/ --format documentation
```

For complete CI integration documentation, see the [CI Integration guide](https://github.com/rayraycodes/rails-accessibility-testing/blob/main/GUIDES/continuous_integration.md) in the main repository.

