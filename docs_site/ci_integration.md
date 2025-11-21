---
layout: default
title: CI Integration
---

# CI/CD Integration

Automating accessibility tests in your Continuous Integration (CI) pipeline ensures no new violations are merged.

---

## GitHub Actions (Recommended)

Add this workflow file to your project at `.github/workflows/accessibility.yml`:

```yaml
name: Accessibility

on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: password
        ports: ['5432:5432']
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
          ruby-version: 3.2
          bundler-cache: true
          
      - name: Install Chrome
        run: |
          sudo apt-get update
          sudo apt-get install -y google-chrome-stable

      - name: Setup Database
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:password@localhost:5432/test_db
        run: |
          bin/rails db:create db:schema:load

      - name: Run Accessibility Tests
        env:
          RAILS_ENV: test
          RAILS_A11Y_PROFILE: ci
        run: |
          bundle exec rspec spec/system/
```

---

## CircleCI

Add this job to your `.circleci/config.yml`:

```yaml
jobs:
  accessibility_check:
    docker:
      - image: cimg/ruby:3.2-browsers
      - image: cimg/postgres:14.0
    environment:
      RAILS_ENV: test
      RAILS_A11Y_PROFILE: ci
    steps:
      - checkout
      - ruby/install-deps
      - run:
          name: Wait for DB
          command: dockerize -wait tcp://localhost:5432 -timeout 1m
      - run:
          name: Database Setup
          command: bin/rails db:schema:load
      - run:
          name: Run Accessibility Scans
          command: bundle exec rspec spec/system/
```

---

## GitLab CI

Add this to your `.gitlab-ci.yml`:

```yaml
accessibility_test:
  image: ruby:3.2
  services:
    - postgres:14
  variables:
    RAILS_ENV: test
    RAILS_A11Y_PROFILE: ci
  before_script:
    - apt-get update -q && apt-get install -y google-chrome-stable
    - bundle install
    - bin/rails db:create db:schema:load
  script:
    - bundle exec rspec spec/system/
```

---

## Best Practices for CI

1.  **Use the CI Profile:** Set `RAILS_A11Y_PROFILE=ci` to enable strict checks (like color contrast) that you might skip in development.
2.  **Fail the Build:** Ensure your tests return a non-zero exit code if accessibility violations are found (this is the default behavior).
3.  **Artifacts:** If using the static scanner's report output, save the generated HTML/JSON report as a build artifact.

```yaml
      - name: Upload Report
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: accessibility-report
          path: coverage/accessibility/
```
