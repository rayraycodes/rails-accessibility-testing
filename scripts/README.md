# Scripts

## create_issues.rb

Creates GitHub issues from POTENTIAL_ISSUES.md

### Prerequisites

1. **GitHub Personal Access Token**
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Select scopes: `repo` (full control of private repositories)
   - Copy the token

### Usage

```bash
# Set your GitHub token
export GITHUB_TOKEN=your_token_here

# Run the script
ruby scripts/create_issues.rb
```

The script will:
1. Parse POTENTIAL_ISSUES.md
2. Show you how many issues will be created
3. Ask for confirmation
4. Create all issues via GitHub API
5. Show summary of created/failed issues

### Notes

- Issues are created with appropriate labels based on their category
- Rate limiting: Script waits 0.5 seconds between requests
- All issues include a note that they were auto-created from POTENTIAL_ISSUES.md

