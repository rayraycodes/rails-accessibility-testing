# GitHub Pages Setup Guide

Complete guide for setting up and deploying the documentation site to GitHub Pages.

## 🚀 Quick Setup (2 minutes)

### Step 1: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** → **Pages** (left sidebar)
3. Under **"Source"**, select **"GitHub Actions"** (NOT "Deploy from a branch")
4. Click **Save**

### Step 2: Deploy

**Option A: Automatic (Recommended)**
- Push any change to `main` branch
- The workflow will automatically deploy

**Option B: Manual**
1. Go to **Actions** tab
2. Select **"Deploy Documentation to GitHub Pages"**
3. Click **"Run workflow"** → Select `main` → **"Run workflow"**

## ✅ Path Isolation

**The documentation deploys ONLY to `/rails-accessibility-testing` path**

This ensures:
- ✅ Your existing GitHub Pages content at root (`/`) is **NOT affected**
- ✅ Your existing `index.html` or other root files are **preserved**
- ✅ The documentation is isolated to `/rails-accessibility-testing/` subdirectory
- ✅ URL: `https://YOUR_USERNAME.github.io/rails-accessibility-testing/`

## 🔄 How It Works

### Automatic Deployment

- **Workflow:** `.github/workflows/pages.yml`
- **Triggers:** Push to `main` when files in `docs_site/` or `GUIDES/` change
- **Process:**
  1. Builds Jekyll site from `docs_site/`
  2. Deploys to `_site/rails-accessibility-testing/`
  3. Site goes live automatically

### Build Configuration

- **Base URL:** `/rails-accessibility-testing` (in `_config.yml`)
- **Build destination:** `_site/rails-accessibility-testing/` (in workflow)
- **Artifact path:** `_site` (contains the subdirectory)

## 📝 Making Updates

1. **Edit documentation:**
   - `docs_site/*.md` - Documentation pages
   - `GUIDES/*.md` - Guide files

2. **Test locally (optional):**
   ```bash
   cd docs_site
   make install
   make serve
   ```
   Visit http://localhost:4000/rails-accessibility-testing/

3. **Commit and push:**
   ```bash
   git add .
   git commit -m "Update documentation"
   git push origin main
   ```

4. **Deployment happens automatically!**

## 🛠️ Troubleshooting

### "Get Pages site failed"

**Cause:** GitHub Pages isn't enabled yet.

**Solution:** Follow Step 1 above to enable GitHub Pages.

### "No such file or directory @ dir_chdir0 - /github/workspace/docs"

**Cause:** GitHub is trying to use the default `jekyll-build-pages` action.

**Solution:** Our workflow uses custom Jekyll build. Make sure:
- Workflow file is `.github/workflows/pages.yml`
- It uses `bundle exec jekyll build` (not `actions/jekyll-build-pages@v1`)
- Working directory is `./docs_site`

### "Pages build failed"

**Solution:**
- Check Actions log for build errors
- Test locally: `cd docs_site && bundle exec jekyll build --baseurl "/rails-accessibility-testing"`
- Verify all required files exist

### "404 Not Found"

**Solution:**
- Wait 1-2 minutes (deployment takes time)
- Visit `/rails-accessibility-testing/` not just root
- Check `baseurl` in `_config.yml` matches repository name

### Check Pages Status

Run diagnostic workflow:
1. Go to **Actions** tab
2. Select **"Check GitHub Pages Setup"**
3. Click **"Run workflow"**
4. Check output for status

## 🔗 Links

- **Live Site:** https://rayraycodes.github.io/rails-accessibility-testing/
- **Workflow:** `.github/workflows/pages.yml`
- **Documentation:** `docs_site/README.md`

## ✅ Verification

After deployment:
1. Check **Actions** tab for green checkmark
2. Visit: `https://YOUR_USERNAME.github.io/rails-accessibility-testing/`
3. Verify root site still works: `https://YOUR_USERNAME.github.io/` (if you have one)

---

**Need help?** Check the workflow logs in the Actions tab or review `.github/workflows/pages.yml`.
