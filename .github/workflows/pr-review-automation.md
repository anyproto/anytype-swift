# Claude Code Review Prompt (GitHub Actions)

## Context Variables
- **REPO**: Repository name (injected by workflow)
- **PR NUMBER**: Pull request number (injected by workflow)
- **COMMIT SHA**: Commit SHA being reviewed (injected by workflow)

## 🚨 EXHAUSTIVENESS REQUIREMENT (READ FIRST)

This review is the ONLY review pass that matters for this commit. You MUST find every issue in a single run — do not defer findings to "next review," do not stop after the first issue, do not post a partial review and exit.

**Mandatory analysis order:**

1. Fetch the COMPLETE diff in one call: `gh pr diff ${PR_NUMBER} --repo ${REPO}`. Do not slice, do not truncate, do not skim. If the diff is large, read it fully before making any tool calls to post comments.
2. Walk every changed file end-to-end. For each file, build an internal findings list covering at minimum: logic errors, race conditions, nil/force-unwrap hazards, missing guards, off-by-one and boundary bugs, memory/retain cycles, incorrect async/actor isolation, broken edge cases, security issues, incorrect Loc usage, missing feature flags, design-system violations (Color/Image/Loc), typos in user-facing strings, dead code, and `CLAUDE.md` / `TASTE_INVARIANTS.md` violations.
3. Only after the findings list is complete across ALL changed files, post the review.
4. Post ALL inline comments in a SINGLE `gh api POST /pulls/${PR_NUMBER}/reviews` call with every comment in one `comments[]` array (see "Batching" below). Do NOT post comments one at a time. Do NOT split the review across multiple API calls.
5. Never emit "I'll look at the rest later" / "further issues may exist" / "due to time constraints." If you are running short on tool turns, cut low-severity nits first, then format/style notes — but never drop a high-severity bug.

**If the same reviewer (you) missed a finding and it only surfaces on the next push, that is a failure of this run.** Plan turn budget accordingly: analysis first, one batched post at the end.

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

### REQUIRED: Batch all inline comments into ONE API call

Every finding with a specific file/line MUST be posted as an inline comment in a single `POST /pulls/${PR_NUMBER}/reviews` call that contains ALL comments in one `comments[]` array. One review, one call, all findings.

Do NOT post inline comments one by one. Do NOT call `POST /reviews` multiple times for the same run. Multiple calls waste turns and cause partial reviews when the turn budget runs out.

**Batched format (this is the default — use it unless a finding genuinely has no file/line):**

```bash
gh api repos/${REPO}/pulls/${PR_NUMBER}/reviews \
  --method POST \
  --field body="Short overall summary, or empty if inline comments speak for themselves" \
  --field event="COMMENT" \
  --field comments[][path]="path/to/FileA.swift" \
  --field comments[][line]=42 \
  --field comments[][body]="**Bug**: Explanation. \`\`\`suggestion
fixed code here
\`\`\`" \
  --field comments[][path]="path/to/FileA.swift" \
  --field comments[][line]=97 \
  --field comments[][body]="**Race condition**: explanation." \
  --field comments[][path]="path/to/FileB.swift" \
  --field comments[][line]=15 \
  --field comments[][body]="**Loc violation**: hardcoded string — use \`Loc.X.y\`."
```

Repeat the `--field comments[][path]` / `--field comments[][line]` / `--field comments[][body]` trio for every finding. GitHub groups them into one review.

**Inline suggestion blocks** (preferred for small, localized fixes) use the same ` ```suggestion ` mechanism inside a comment's body — still inside the batched call.

### Use a single top-level comment ONLY when there are no line-specific findings

If every finding is cross-cutting (architecture, multi-file design problems, something without a natural line anchor):

```bash
gh pr comment ${PR_NUMBER} --repo ${REPO} --body "YOUR_REVIEW_TEXT_HERE"
```

Do NOT post BOTH a batched review AND a separate `gh pr comment` summary for the same run — that produces duplicate noise. The `body` field of the `POST /reviews` call already serves as the summary.

## CRITICAL: Post Your Review

**YOU MUST POST YOUR REVIEW TO THE PR** - analysis alone is not sufficient.

After completing your review analysis:

1. **For reviews with inline comments**: Post ONE batched `POST /pulls/${PR_NUMBER}/reviews` call containing every inline comment in one `comments[]` array. Do not post a separate summary comment — use the `body` field of that same call.
2. **For reviews without inline comments**: Post your full review text as a single `gh pr comment` call.

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

