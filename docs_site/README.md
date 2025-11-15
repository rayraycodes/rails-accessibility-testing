# Documentation Site

This is a **Jekyll-based** documentation site for Rails Accessibility Testing. It automatically generates HTML pages from markdown files and is compatible with GitHub Pages.

## Why Jekyll?

- ✅ **Auto-updating** - Pages automatically reflect changes to source markdown
- ✅ **GitHub Pages compatible** - Deploy directly to GitHub Pages
- ✅ **Sustainable** - No manual HTML maintenance needed
- ✅ **Markdown-based** - Easy to write and maintain
- ✅ **Isolated path** - Deploys only to `/rails-accessibility-testing` path, doesn't affect root

## Quick Start

### Option 1: Using Make (Recommended)

```bash
cd docs_site
make install    # Install dependencies
make serve      # Serve locally with live reload
```

Visit http://localhost:4000/rails-accessibility-testing/

### Option 2: Manual Setup

1. Install Jekyll and dependencies:

```bash
cd docs_site
bundle install
```

2. Serve locally:

```bash
bundle exec jekyll serve --baseurl "/rails-accessibility-testing"
```

Visit http://localhost:4000/rails-accessibility-testing/

## Structure

- `index.md` - Home page
- `getting_started.md` - Getting started guide
- `configuration.md` - Configuration documentation
- `ci_integration.md` - CI integration guide
- `contributing.md` - Contributing guide
- `_config.yml` - Jekyll configuration
- `_layouts/default.html` - Page layout template
- `_includes/header.html` - Navigation header

## Important: Path Isolation

The documentation site is configured to deploy **only** to the `/rails-accessibility-testing` path:

- **Base URL:** `/rails-accessibility-testing`
- **Build destination:** `../_site/rails-accessibility-testing`
- **Live URL:** `https://YOUR_USERNAME.github.io/rails-accessibility-testing/`

This ensures:
- ✅ Doesn't interfere with existing GitHub Pages content at root
- ✅ Doesn't overwrite existing `index.html` or other files
- ✅ Isolated deployment path

## Deployment

### GitHub Pages (Automatic)

The documentation is **automatically deployed** to GitHub Pages via GitHub Actions when you push to the `main` branch.

**Live Site:** https://rayraycodes.github.io/rails-accessibility-testing/

**Setup:**
1. Go to repository Settings → Pages
2. Under "Source", select "GitHub Actions"
3. The workflow (`.github/workflows/pages.yml`) will automatically deploy on push to `main`

**Important:** The site deploys to `/rails-accessibility-testing` subdirectory, not the root. This preserves any existing GitHub Pages content.

### Manual Build

```bash
bundle exec jekyll build --baseurl "/rails-accessibility-testing"
```

Output will be in `_site/rails-accessibility-testing/` directory.

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

## Troubleshooting

### Build errors

If you see errors about missing directories:
- Make sure you're in the `docs_site/` directory
- Run `bundle install` to install dependencies
- Check `_config.yml` for correct paths

### Path issues

If links don't work:
- Make sure `baseurl` in `_config.yml` is `/rails-accessibility-testing`
- Use `relative_url` filter in links: `{{ '/page.html' | relative_url }}`
- Test locally with `--baseurl "/rails-accessibility-testing"`
