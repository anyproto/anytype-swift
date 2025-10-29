Commit, push, pull request

## Usage
```
/cpp [in branch <branch-name>]
```

## Description
Commits the current changes, pushes to remote, and creates a pull request.

## Optional Arguments
- `in branch <branch-name>` - Specifies the target branch to use for the commit, push, and PR

## Branch Handling
When a branch name is provided:
1. **Branch doesn't exist locally or remotely**: Creates a new branch with the specified name
2. **Branch exists locally**: Switches to that branch
3. **Branch exists only remotely**: Checks out the remote branch locally

## Examples
```bash
# Commit, push, and PR on current branch
/cpp

# Commit, push, and PR on specific branch (creates if doesn't exist)
/cpp in branch ios-5364-add-claude-to-gh-actions

# Commit, push, and PR on existing branch
/cpp in branch develop
```
