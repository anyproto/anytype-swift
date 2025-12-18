# Claude Code Review Prompt (GitHub Actions)

## Context Variables
- **REPO**: Repository name (injected by workflow)
- **PR NUMBER**: Pull request number (injected by workflow)
- **COMMIT SHA**: Commit SHA being reviewed (injected by workflow)

## 🚨 CRITICAL OUTPUT RULES

**If NO issues found:**
```
✅ **Approved** - No issues found
```

**DO NOT add ANY additional text:**
- ❌ NO "The PR correctly implements..."
- ❌ NO explanations of what changed
- ❌ NO lists of what was added/cleaned
- ❌ NO implementation details
- ❌ ONLY the one-line approval message above

**If issues ARE found:**
Follow the format from `.claude/skills/code-review-developer/SKILL.md`

## CI-Specific Reference Documentation

### Valid GitHub Actions Runners
https://github.com/actions/runner-images/tree/main/images/macos

### macOS Runner to Xcode Version Mapping
- `macos-15`: Xcode 15.x (e.g., '15.4') - See https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md
- `macos-26`: Xcode 26.1 (at /Applications/Xcode_26.1.app) - See https://github.com/actions/runner-images/blob/main/images/macos/macos-26-arm64-Readme.md

**VALIDATION RULE**: When reviewing xcode-version in workflows, verify it matches the runs-on runner version using the mapping above.

## Review Comment Strategy

### 1. Small, Localized Issues (Preferred)
For issues affecting a single chunk of code:
- Use GitHub's suggestion mechanism to propose the fix inline
- Include the fixed code in a suggestion block
- Add brief explanation above the suggestion

**Format**:
```suggestion
fixed code here
```

**Example**:
```bash
gh api repos/${REPO}/pulls/${PR_NUMBER}/reviews \
  --method POST \
  --field body="" \
  --field event="COMMENT" \
  --field comments[][path]="fastlane/FastlaneComment" \
  --field comments[][line]=45 \
  --field comments[][body]="**Code Quality**: This single-line command is fragile. Consider breaking into multiple lines:
\`\`\`suggestion
sh(\"export PKG_CONFIG_PATH=/opt/homebrew/lib/pkgconfig:/usr/local/lib/pkgconfig:\$PKG_CONFIG_PATH\")
sh(\"source venv/bin/activate && pip3 install -r requirements.txt && python3 release-utils/main.py\")
\`\`\`"
```

### 2. Broader Issues (Multiple Locations)
For issues spanning multiple files or no immediate fix:

**Format**:
```bash
gh api repos/${REPO}/pulls/${PR_NUMBER}/reviews \
  --method POST \
  --field body="Your summary here (can be empty if you have inline comments)" \
  --field event="COMMENT" \
  --field comments[][path]="Anytype/Sources/PresentationLayer/SpaceSettings/SpaceSettings/SpaceSettingsViewModel.swift" \
  --field comments[][line]=274 \
  --field comments[][body]="**Potential Race Condition**: canAddWriters is computed using participants array (line 274), but participants is updated asynchronously in startJoiningTask() which runs in parallel with startParticipantTask()."
```

You can add multiple `--field comments[][...]` entries in a single command for multiple inline comments.

### 3. Final Summary Comment
Always post a summary at the end:
```bash
gh pr comment ${PR_NUMBER} --body "Review complete - see inline comments for details"
```

## CRITICAL: Post Your Review

**YOU MUST POST YOUR REVIEW TO THE PR** - analysis alone is not sufficient.

After completing your review analysis:

1. **For reviews with inline comments**: Post inline comments first using the strategies above, then post a final summary
2. **For reviews without inline comments**: Post your full review text as a single PR comment

**Command**:
```bash
gh pr comment ${PR_NUMBER} --repo ${REPO} --body "YOUR_REVIEW_TEXT_HERE"
```

**Example** (clean approval):
```bash
gh pr comment ${PR_NUMBER} --repo ${REPO} --body "✅ **Approved** - No issues found"
```

**Example** (review with issues):
```bash
gh pr comment ${PR_NUMBER} --repo ${REPO} --body "## Bugs/Issues

**SpaceHubToolbar.swift:109**
The \`attentionDotView\` overlay positioning is incorrect...

---

⚠️ **Minor Issues** - Fix overlay positioning"
```

**Important**:
- Use single quotes to wrap multi-line review text if needed
- Escape special characters appropriately for bash
- Always include the status emoji summary at the end (as defined in shared guidelines)
- The workflow provides ${PR_NUMBER} and ${REPO} variables

