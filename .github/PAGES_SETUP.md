# GitHub Pages Setup Guide

This repository uses GitHub Actions to automatically deploy the Jekyll documentation site to GitHub Pages.

## Automatic Deployment

The documentation site is automatically deployed when you push to the `main` branch (if files in `docs_site/` or `GUIDES/` change).

**Live Site:** https://rayraycodes.github.io/rails-accessibility-testing/

## Initial Setup

1. **Enable GitHub Pages:**
   - Go to repository Settings → Pages
   - Under "Source", select **"GitHub Actions"**
   - Save

2. **First Deployment:**
   - Push to `main` branch
   - GitHub Actions will automatically build and deploy
   - Check Actions tab for deployment status

## How It Works

1. **Workflow:** `.github/workflows/pages.yml`
   - Triggers on push to `main` when docs change
   - Builds Jekyll site from `docs_site/`
   - Deploys to GitHub Pages

2. **Preview:** `.github/workflows/docs-preview.yml`
   - Runs on pull requests
   - Validates that site builds correctly
   - Doesn't deploy (just checks)

## Manual Deployment

If you need to manually trigger a deployment:

1. Go to **Actions** tab
2. Select **"Deploy Documentation to GitHub Pages"**
3. Click **"Run workflow"**
4. Select branch and click **"Run workflow"**

## Troubleshooting

### Site not updating?
- Check Actions tab for failed workflows
- Verify GitHub Pages is set to "GitHub Actions" source
- Check that workflow file is in `.github/workflows/pages.yml`

### Build errors?
- Run locally: `cd docs_site && bundle exec jekyll build`
- Check for syntax errors in markdown files
- Verify all required files exist

### 404 errors?
- Check `baseurl` in `_config.yml` matches repository name
- Verify all links use `relative_url` filter
- Check that pages exist in `docs_site/`

## Local Testing

Before pushing, test locally:

```bash
cd docs_site
make install
make serve
```

Visit http://localhost:4000 to preview changes.

