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

### 0. Determine Branch Name (if not provided)
- If user mentions a Linear task ID (e.g., IOS-5292), fetch the issue using `mcp__linear-server__list_issues`
- Extract the `gitBranchName` field from the Linear issue response
- Use this exact branch name for checkout/creation

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

### 5. Review Findings - ALWAYS Wait for Approval
- Present review results to developer
- **If ANY issues found (including minor/non-blocking)**: STOP and wait for developer decision:
  - Should we fix the issues now?
  - Are the findings valid or false positives?
  - Should we proceed anyway?
- **Developer decides next steps** - never auto-amend commits, never auto-proceed to push/PR
- Only proceed to step 6 when developer explicitly approves

### 6. Push and PR (only after explicit approval)
- Push to remote with tracking
- Create pull request with summary
- **Requires explicit approval** - do not auto-proceed even for "clean" reviews with minor notes

## Branch Handling
When a branch name is provided:
1. **Branch doesn't exist locally or remotely**: Creates a new branch with the specified name
2. **Branch exists locally**: Switches to that branch
3. **Branch exists only remotely**: Checks out the remote branch locally

## Prerequisites
When working with Linear tasks, Claude should fetch the branch name before running `/cpp`:
1. User mentions task ID (e.g., "Fix IOS-2532")
2. Claude calls `mcp__linear-server__list_issues(query: "IOS-2532", limit: 1)`
3. Claude extracts `gitBranchName` field (e.g., "ios-2532-fix-comment-version-for-hotfix")
4. Claude switches to that branch
5. User runs `/cpp` on the correct branch

## Examples
```bash
# Commit, review, push, and PR on current branch
/cpp

# Commit, review, push, and PR on specific branch (creates if doesn't exist)
/cpp in branch ios-5364-add-claude-to-gh-actions
```
