---
allowed-tools: Bash(git branch:*), Bash(git diff:*), Bash(git fetch:*)
---

# Code Review Command

Review local code changes on the current branch against a base branch.

## Git Context (Precomputed)
- **Fetch**: !`git fetch origin develop 2>/dev/null || echo "(fetch failed - origin may not exist)"`
- **Current branch**: !`git branch --show-current`

> **Note**: If fetch fails (fresh clone, no remote), run `git fetch origin` first or use local branches.

## Usage
```
/codeReview [to branch <base>]
```

## Optional Arguments
- `to branch <base>` - Base branch to compare against (default: `develop`)

## Process

### Step 1: Get Changed Files
Use the user-specified base branch, or `develop` if not specified:

```bash
# Get changed files and diff stats
git diff --name-status origin/<base>...HEAD
git diff --stat origin/<base>...HEAD

# Get full diff for review
git diff origin/<base>...HEAD
```

### Step 2: Apply Review Standards

**Apply the shared review guidelines from:**
`.claude/CODE_REVIEW_GUIDE.md`

Follow all core rules, review sections, common mistakes, and analysis checklist defined in that file.

**Also consult:**
- `.claude/skills/code-review-developer/SKILL.md` - Quick reference for critical rules and workflow

**Context adaptation for local reviews:**
- This is a local review (not a GitHub PR)
- Reference file:line locations from the git diff
- Focus on changes between current branch and the base branch
- Output review directly (no need to post comments)

### Step 3: Review Focus Areas

When analyzing the diff, pay special attention to:

1. **Migration to @Observable**: Check that all properties are properly annotated and dependencies marked with `@ObservationIgnored`
2. **Localization**: Ensure no hardcoded strings in UI, all text uses `Loc.*` constants
3. **Feature Flags**: New features should be wrapped in `FeatureFlags.*` checks
4. **Generated Files**: Never manually edit files marked with `// Generated using Sourcery/SwiftGen`
5. **Tests & Mocks**: When refactoring, ensure tests and mocks are updated
6. **Unused Code**: After refactoring, check that old code is removed
7. **Comments**: Only add if explicitly needed (per CLAUDE.md guidelines)
8. **Dependency Injection in Structs**: Avoid using `@Injected` properties in structs - dependency resolution happens on every struct recreation. Use classes with `@Observable` instead. See [PR #4173](https://github.com/anyproto/anytype-swift/pull/4173)

### Step 4: Output Review

Present the review following the summary format from the shared guidelines.

Include detailed findings for each issue category only if issues are found.
