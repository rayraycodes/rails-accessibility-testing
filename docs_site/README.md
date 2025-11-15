# Documentation Site

This is a **Jekyll-based** documentation site for Rails Accessibility Testing. It automatically generates HTML pages from markdown files and is compatible with GitHub Pages.

## Why Jekyll?

- ✅ **Auto-updating** - Pages automatically reflect changes to source markdown
- ✅ **GitHub Pages compatible** - Deploy directly to GitHub Pages
- ✅ **Sustainable** - No manual HTML maintenance needed
- ✅ **Markdown-based** - Easy to write and maintain

## Quick Start

### Option 1: Using Make (Recommended)

```bash
cd docs_site
make install    # Install dependencies
make serve      # Serve locally with live reload
```

Visit http://localhost:4000

### Option 2: Manual Setup

1. Install Jekyll and dependencies:

```bash
cd docs_site
bundle install
```

2. Serve locally:

```bash
bundle exec jekyll serve --livereload
```

Visit http://localhost:4000

## Structure

- `index.md` - Home page
- `getting_started.md` - Includes content from GUIDES/getting_started.md
- `configuration.md` - Configuration documentation
- `ci_integration.md` - Includes content from GUIDES/continuous_integration.md
- `contributing.md` - Includes content from CONTRIBUTING.md
- `_config.yml` - Jekyll configuration
- `_layouts/default.html` - Page layout template
- `_includes/header.html` - Navigation header

## Auto-Updating

The site automatically includes content from the main GUIDES directory using `include_relative`, so when you update the guides, the documentation site updates automatically.

## Deployment

### GitHub Pages (Automatic)

The documentation is **automatically deployed** to GitHub Pages via GitHub Actions when you push to the `main` branch.

**Live Site:** https://rayraycodes.github.io/rails-accessibility-testing/

**Setup:**
1. Go to repository Settings → Pages
2. Under "Source", select "GitHub Actions"
3. The workflow (`.github/workflows/pages.yml`) will automatically deploy on push to `main`

**Manual Deployment:**
If you need to manually trigger a deployment:
1. Go to Actions tab
2. Select "Deploy Documentation to GitHub Pages"
3. Click "Run workflow"

### Manual Build

```bash
bundle exec jekyll build
```

Output will be in `_site/` directory.

## Adding New Pages

1. Create a new `.md` file in `docs_site/`
2. Add front matter:

```yaml
---
layout: default
title: Page Title
---
```

3. Add link to navigation in `_includes/header.html`
