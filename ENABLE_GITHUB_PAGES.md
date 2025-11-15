# GitHub Pages Setup Guide

Complete guide for setting up and deploying the documentation site to GitHub Pages.

## 🚀 Quick Setup (2 minutes)

### Step 1: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** → **Pages** (left sidebar)
3. Under **"Source"**, select **"GitHub Actions"** (NOT "Deploy from a branch")
4. **IMPORTANT:** Make sure "Deploy from a branch" is NOT selected
5. Click **Save**

**If you see errors about `jekyll-build-pages` or `/docs` directory:**
- This means GitHub is trying to use the default Jekyll build
- Make absolutely sure Pages source is set to "GitHub Actions" only
- The `.nojekyll` file in the repo root prevents auto-detection

### Step 1.5: Authentication (Optional - Usually Not Needed)

The workflow uses **OIDC tokens** by default (most secure). If you encounter authentication errors:

1. **Create a Personal Access Token (PAT):**
   - Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with scopes: `repo` and `pages`
   - Copy the token

2. **Add as Secret:**
   - Go to repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `PAGES_TOKEN` (or `GITHUB_TOKEN`)
   - Value: Paste your PAT
   - Click "Add secret"

3. **The workflow will automatically use it** if OIDC fails

**Note:** OIDC should work for most repositories. Only add a PAT if you see authentication errors.

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

### "404 Not Found" - Deployment Successful But Page Not Found

**If deployment shows success but you get 404:**

This is usually a **propagation delay** or **caching issue**. Try these steps in order:

1. **Wait 1-2 minutes** - GitHub Pages needs time to propagate changes
2. **Clear browser cache** or use **incognito/private mode**
3. **Check the exact URL:**
   - ✅ Correct: `https://YOUR_USERNAME.github.io/rails-accessibility-testing/` (with trailing slash)
   - ✅ Also try: `https://YOUR_USERNAME.github.io/rails-accessibility-testing/index.html`
   - ❌ Wrong: `https://YOUR_USERNAME.github.io/rails-accessibility-testing` (no trailing slash)
4. **Verify deployment:**
   - Go to **Actions** tab → Check workflow completed successfully
   - Look for "✅ index.html found" in the logs
   - Check "Deployment info" step shows correct URL
5. **Check repository Settings → Pages:**
   - Source should be "GitHub Actions"
   - Should show "Your site is live at: https://YOUR_USERNAME.github.io/"

**If 404 persists after 5 minutes:**
- Check workflow logs for any errors
- Verify artifact structure shows `rails-accessibility-testing/index.html`
- Try visiting the direct file: `https://YOUR_USERNAME.github.io/rails-accessibility-testing/index.html`

### URL shows `/site/` in path

**If you see `/site/` in the URL:**

This usually means:
1. **Repository name mismatch** - Check that repository is named `rails-accessibility-testing`
2. **Pages source wrong** - Make sure Pages source is "GitHub Actions" not "Deploy from a branch"
3. **Custom domain issue** - If custom domain is configured, it might affect paths

**Solution:**
- **Correct URL:** `https://YOUR_USERNAME.github.io/rails-accessibility-testing/`
- **Wrong URL:** `https://YOUR_USERNAME.github.io/site/rails-accessibility-testing/`
- Go to **Settings** → **Pages** → Verify source is "GitHub Actions"
- Check repository name matches expected path

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
