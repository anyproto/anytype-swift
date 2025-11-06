Commit, review, push, pull request

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
- If user mentions a Linear task ID (e.g., IOS-5292), fetch the issue using `mcp__linear__list_issues`
- Extract the `gitBranchName` field from the Linear issue response
- Use this exact branch name for checkout/creation

### 1. Commit Changes
- Stage and commit all changes with a descriptive message
- Follow CLAUDE.md commit message guidelines

### 2. Code Review
- Run automated code review using `/codeReview` workflow
- Apply CODE_REVIEW_GUIDE.md standards
- Check for bugs, best practices violations, performance issues, security concerns

### 3. Review Findings and Auto-Proceed
- Present review results to developer
- If issues found, **STOP and discuss** with developer:
  - Should we fix the issues now?
  - Are the findings valid or false positives?
  - Should we proceed anyway?
- **Developer decides next steps** - never auto-amend commits
- **If review is approved (✅)**: Automatically proceed to push and PR without asking

### 4. Push and PR (auto-proceed when approved)
- Push to remote with tracking
- Create pull request with summary
- No confirmation needed when code review is approved

## Branch Handling
When a branch name is provided:
1. **Branch doesn't exist locally or remotely**: Creates a new branch with the specified name
2. **Branch exists locally**: Switches to that branch
3. **Branch exists only remotely**: Checks out the remote branch locally

## Prerequisites
When working with Linear tasks, Claude should fetch the branch name before running `/cpp`:
1. User mentions task ID (e.g., "Fix IOS-2532")
2. Claude calls `mcp__linear__list_issues(query: "IOS-2532", limit: 1)`
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
