---
allowed-tools: Bash(git branch:*), Bash(git status:*), Bash(git log:*), Bash(git diff:*), Bash(git fetch:*)
---

# Commit, review, push, pull request

## Git Context (Precomputed)
- **Fetch**: !`git fetch origin develop 2>/dev/null || echo "(fetch failed)"`
- **Current branch**: !`git branch --show-current`
- **Staged files**: !`git diff --cached --name-only`
- **Unstaged changes**: !`git status --short`
- **Recent commits**: !`git log --oneline -5`

## Usage
```
/cpp [in branch <branch-name>]
```

## Description
Commits the current changes, performs a code review, applies fixes if needed, then pushes to remote and creates a pull request.

## Optional Arguments
- `in branch <branch-name>` - Specifies the target branch to use for the commit, push, and PR

## Workflow

### 0. MANDATORY: Verify Correct Branch
**ALWAYS check the branch before any commit operations:**

1. **If task name/ID is known** (from conversation context, branch name pattern, or user mention):
   - Fetch the Linear issue using `mcp__linear-server__list_issues(query: "IOS-XXXX")`
   - Extract the `gitBranchName` field from the response
   - Compare with current branch (`git branch --show-current`)
   - If mismatch: **STOP** and ask user to confirm branch switch

2. **If task name/ID is NOT known**:
   - **STOP and ask the user**: "What Linear task are you working on? (e.g., IOS-5292)"
   - Wait for response before proceeding
   - Then fetch and verify branch as above

3. **Branch verification outcomes**:
   - ✅ Current branch matches Linear task's `gitBranchName` → proceed
   - ⚠️ Branch mismatch → ask user: "Switch to `<correct-branch>` or continue on current branch?"
   - ❌ No task ID provided → do NOT proceed until user provides it

**Never commit without verifying you're on the correct branch for the task.**

### 1. Stage Changes
- Stage all changes to prepare for review and commit

### 2. Polish Code (simplify + cleanup)
- Review staged Swift files for simplification opportunities
- **If no opportunities found**: Auto-proceed to commit (no approval needed)
- **If opportunities found**: Present findings, wait for explicit approval before making ANY changes
- If user approves: apply changes, re-stage, then continue to commit
- If user declines: skip polish, proceed to commit as-is
- Key checks: guard-let early returns, keypath shorthand (where clearer), unused code removal

### 3. Commit Changes
- Commit staged changes with a descriptive message
- Follow CLAUDE.md commit message guidelines

### 4. Code Review
- Run automated code review using `/codeReview` workflow
- Apply CODE_REVIEW_GUIDE.md standards
- Check for bugs, best practices violations, performance issues, security concerns

### 5. Review Findings
- Present review results to developer
- **If NO issues found AND nothing polished**: Auto-proceed to push/PR (no approval needed)
- **If ANY issues found (including minor/non-blocking)**: STOP and wait for developer decision:
  - Should we fix the issues now?
  - Are the findings valid or false positives?
  - Should we proceed anyway?
- **Developer decides next steps** - never auto-amend commits

### 6. Push and PR
- Push to remote with tracking
- Create pull request with summary

## Branch Handling
When a branch name is provided:
1. **Branch doesn't exist locally or remotely**: Creates a new branch with the specified name
2. **Branch exists locally**: Switches to that branch
3. **Branch exists only remotely**: Checks out the remote branch locally

## Branch Verification (Built-in)
The `/cpp` command now **automatically verifies** the correct branch:
1. If task ID is known (from context or branch name) → fetches Linear issue and verifies branch
2. If task ID is unknown → **asks user before proceeding**
3. Switches branch if needed (with user confirmation)

## Examples
```bash
# Commit, review, push, and PR on current branch
/cpp

# Commit, review, push, and PR on specific branch (creates if doesn't exist)
/cpp in branch ios-5364-add-claude-to-gh-actions
```
