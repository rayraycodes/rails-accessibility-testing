# How to Set GitHub Token

## Quick Start (Recommended for One-Time Use)

1. **Get Token**: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Check "repo" scope
   - Copy the token (starts with `ghp_`)

2. **Set Token** (temporary - only for current terminal):
   ```bash
   export GITHUB_TOKEN=ghp_your_token_here
   ```

3. **Verify**:
   ```bash
   echo $GITHUB_TOKEN
   ```

4. **Run Script**:
   ```bash
   ruby scripts/create_issues.rb
   ```

## Detailed Instructions

### Step 1: Create GitHub Personal Access Token

1. Visit: https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Name it: "Rails A11y Issue Creator"
4. Select scope: **`repo`** (Full control of private repositories)
5. Click "Generate token"
6. **Copy the token immediately** - you won't see it again!

### Step 2: Set the Token

**Option A: Temporary (Current Session Only)** ⭐ Recommended
```bash
export GITHUB_TOKEN=ghp_your_token_here
```

**Option B: Permanent (Add to Shell Profile)**
```bash
# For zsh (macOS default):
echo 'export GITHUB_TOKEN=ghp_your_token_here' >> ~/.zshrc
source ~/.zshrc

# For bash:
echo 'export GITHUB_TOKEN=ghp_your_token_here' >> ~/.bashrc
source ~/.bashrc
```

**Option C: Secure Storage (macOS Keychain)**
```bash
# Store securely:
security add-generic-password -a github_token -s github -w ghp_your_token_here

# Retrieve when needed:
export GITHUB_TOKEN=$(security find-generic-password -a github_token -s github -w)
```

**Option D: Environment File**
```bash
# Create .env file (already in .gitignore):
echo 'GITHUB_TOKEN=ghp_your_token_here' > .env

# Load it:
export $(cat .env | xargs)
```

### Step 3: Verify Token is Set

```bash
echo $GITHUB_TOKEN
# Should show: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Step 4: Run the Issue Creation Script

```bash
cd /Users/imregan/workprojects/rails-accessibility-testing
ruby scripts/create_issues.rb
```

## Security Notes

⚠️ **Important:**
- Never commit tokens to git (`.env` is already in `.gitignore`)
- Use temporary tokens when possible
- Revoke tokens if compromised: https://github.com/settings/tokens
- Token gives access to your repos - keep it secret!

## Troubleshooting

**Token not found:**
```bash
# Check if it's set:
echo $GITHUB_TOKEN

# If empty, set it again:
export GITHUB_TOKEN=ghp_your_token_here
```

**Permission denied:**
- Make sure you selected "repo" scope when creating the token
- Verify the token hasn't expired

**Script can't authenticate:**
- Double-check the token starts with `ghp_`
- Make sure there are no extra spaces when setting it
- Try regenerating the token

## Links

- Create Token: https://github.com/settings/tokens
- Manage Tokens: https://github.com/settings/tokens
- Repository Issues: https://github.com/rayraycodes/rails-accessibility-testing/issues

