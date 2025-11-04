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

### 1. Commit Changes
- Stage and commit all changes with a descriptive message
- Follow CLAUDE.md commit message guidelines

### 2. Code Review
- Run automated code review using `/codeReview` workflow
- Apply CODE_REVIEW_GUIDE.md standards
- Check for bugs, best practices violations, performance issues, security concerns

### 3. Review Findings
- Present review results to developer
- If issues found, **STOP and discuss** with developer:
  - Should we fix the issues now?
  - Are the findings valid or false positives?
  - Should we proceed anyway?
- **Developer decides next steps** - never auto-amend commits

### 4. Push and PR (when approved)
- Only proceed when developer approves
- Push to remote with tracking
- Create pull request with summary

## Branch Handling
When a branch name is provided:
1. **Branch doesn't exist locally or remotely**: Creates a new branch with the specified name
2. **Branch exists locally**: Switches to that branch
3. **Branch exists only remotely**: Checks out the remote branch locally

## Examples
```bash
# Commit, review, push, and PR on current branch
/cpp

# Commit, review, push, and PR on specific branch (creates if doesn't exist)
/cpp in branch ios-5364-add-claude-to-gh-actions

# Commit, review, push, and PR on existing branch
/cpp in branch develop
```
