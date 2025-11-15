# Continuous Integration with Rails A11y

This guide shows you how to integrate Rails A11y into your CI/CD pipeline to catch accessibility issues before they reach production.

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
      
      - name: Upload accessibility report
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: accessibility-report
          path: accessibility-report.json
```

### Advanced: JSON Report

Generate a JSON report for programmatic access:

```yaml
- name: Run accessibility tests with JSON report
  run: |
    bundle exec rails_a11y check --format json --output accessibility-report.json
```

### Comment on PR

Add a comment to PRs with accessibility status:

```yaml
- name: Comment on PR
  if: github.event_name == 'pull_request'
  uses: actions/github-script@v6
  with:
    script: |
      const fs = require('fs');
      const report = JSON.parse(fs.readFileSync('accessibility-report.json', 'utf8'));
      
      const comment = `## Accessibility Report
      
      **Status:** ${report.summary.total_violations === 0 ? '✅ Pass' : '❌ Fail'}
      **Violations:** ${report.summary.total_violations}
      **URLs Checked:** ${report.summary.urls_checked}
      
      ${report.summary.total_violations > 0 ? 'Please fix accessibility issues before merging.' : 'All accessibility checks passed!'}
      `;
      
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: comment
      });
```

## CircleCI

### Basic Configuration

Add to `.circleci/config.yml`:

```yaml
version: 2.1

jobs:
  accessibility:
    docker:
      - image: cimg/ruby:3.1
        environment:
          RAILS_ENV: test
    steps:
      - checkout
      - restore_cache:
          keys:
            - v1-dependencies-{{ checksum "Gemfile.lock" }}
      - run:
          name: Install dependencies
          command: bundle install
      - run:
          name: Setup database
          command: bundle exec rails db:create db:schema:load
      - run:
          name: Run accessibility tests
          command: bundle exec rspec spec/system/
```

## GitLab CI

### Basic Configuration

Add to `.gitlab-ci.yml`:

```yaml
accessibility:
  image: ruby:3.1
  services:
    - postgres:14
  variables:
    RAILS_ENV: test
    POSTGRES_DB: test
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
  before_script:
    - apt-get update -qq && apt-get install -y -qq postgresql-client
    - bundle install
    - bundle exec rails db:create db:schema:load
  script:
    - bundle exec rspec spec/system/
  artifacts:
    when: on_failure
    paths:
      - accessibility-report.json
    reports:
      junit: accessibility-report.xml
```

## Jenkins

### Pipeline Script

```groovy
pipeline {
    agent any
    
    stages {
        stage('Accessibility Tests') {
            steps {
                sh 'bundle install'
                sh 'bundle exec rails db:create db:schema:load RAILS_ENV=test'
                sh 'bundle exec rspec spec/system/'
            }
        }
    }
    
    post {
        always {
            archiveArtifacts artifacts: 'accessibility-report.json', allowEmptyArchive: true
        }
    }
}
```

## CI Configuration Tips

### Use CI Profile

Configure stricter checks in CI:

```yaml
# config/accessibility.yml
ci:
  checks:
    color_contrast: true   # Enable expensive checks in CI
    skip_links: true       # Require skip links in production
```

Then set the profile in CI:

```bash
RAILS_A11Y_PROFILE=ci bundle exec rspec spec/system/
```

### Fail Fast

Make accessibility failures block merges:

```yaml
# GitHub Actions
- name: Run accessibility tests
  run: bundle exec rspec spec/system/
  continue-on-error: false  # Fail the build on errors
```

### Parallel Execution

Run accessibility tests in parallel with other tests:

```yaml
strategy:
  matrix:
    test_type: [unit, integration, accessibility]
```

### Cache Dependencies

Speed up CI runs by caching:

```yaml
- name: Cache gems
  uses: actions/cache@v3
  with:
    path: vendor/bundle
    key: ${{ runner.os }}-gems-${{ hashFiles('**/Gemfile.lock') }}
```

## Reporting

### Generate Reports

```bash
# Human-readable report
bundle exec rails_a11y check --format human --output report.txt

# JSON report for programmatic access
bundle exec rails_a11y check --format json --output report.json
```

### Share Reports

Upload reports to:
- **GitHub Actions Artifacts** - Automatic artifact upload
- **S3/Cloud Storage** - For long-term storage
- **Slack/Email** - Notify team of failures

## Best Practices

1. **Run on every PR** - Catch issues before merge
2. **Use CI profile** - Stricter checks in CI than dev
3. **Fail on violations** - Don't allow merging with issues
4. **Report results** - Make status visible to team
5. **Track trends** - Monitor violation counts over time

## Troubleshooting

### Tests Time Out

If tests are slow, disable expensive checks:

```yaml
ci:
  checks:
    color_contrast: false  # Disable if too slow
```

### Chrome Not Found

Install Chrome in CI:

```yaml
- name: Install Chrome
  run: |
    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
    sudo apt-get update
    sudo apt-get install -y google-chrome-stable
```

### Database Issues

Ensure database is set up:

```bash
bundle exec rails db:create db:schema:load RAILS_ENV=test
```

## Next Steps

- **Set up notifications** - Get alerts when checks fail
- **Track metrics** - Monitor accessibility over time
- **Automate fixes** - Use reports to prioritize work

---

**Questions?** See the main [README](../README.md) or open an issue.

