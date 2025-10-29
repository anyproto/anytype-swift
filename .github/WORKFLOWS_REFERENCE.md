# GitHub Workflows & Actions Reference

This document provides an overview of GitHub workflows, custom actions, and automation in the Anytype iOS repository. For implementation details, refer to the source files in `.github/workflows/` and `.github/actions/`.

## Table of Contents

- [Quick Reference](#quick-reference)
- [Workflows](#workflows)
  - [CI/CD Workflows](#cicd-workflows)
  - [Automation Workflows](#automation-workflows)
  - [Code Quality Workflows](#code-quality-workflows)
  - [AI/Code Review Workflows](#aicode-review-workflows)
  - [Utility Workflows](#utility-workflows)
- [Custom Actions](#custom-actions)
- [Auto-merge System](#auto-merge-system)
- [Required Secrets & Variables](#required-secrets--variables)
- [Runner Configuration](#runner-configuration)
- [Best Practices](#best-practices)

## Quick Reference

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `pr_tests.yml` | PR, manual | Run unit tests on PRs |
| `generator_checks.yaml` | PR, manual | Verify generated files are up-to-date |
| `automerge.yaml` | PR from `any-association` | Auto-approve and merge bot PRs |
| `update_middleware.yaml` | Manual, called | Update middleware version |
| `update_middleware_nightly.yaml` | Schedule (weekdays 03:00 UTC), manual | Update to latest nightly middleware |
| `branch_build.yaml` | Manual | Build and upload branch to TestFlight |
| `dev_build.yaml` | Schedule (weekdays 05:00 UTC), manual | Daily dev build to TestFlight |
| `claude-code-review.yml` | PR opened | AI-powered code review with Claude |

## Workflows

### CI/CD Workflows

#### `pr_tests.yml` - Unit Tests
**File:** `.github/workflows/pr_tests.yml`
**Triggers:** Pull requests, manual dispatch
**Purpose:** Runs unit tests on all PRs to ensure code quality before merge. Uses Xcode cache for faster builds and cancels in-progress runs when new commits are pushed.

---

#### `branch_build.yaml` - Manual TestFlight Upload
**File:** `.github/workflows/branch_build.yaml`
**Triggers:** Manual dispatch only
**Purpose:** Builds the current branch and uploads to TestFlight with an optional comment. Sends Slack notification on completion.
**Inputs:** `tf_comment` (optional TestFlight comment)
**Notable:** Does not cancel in-progress builds

---

#### `dev_build.yaml` - Scheduled Dev Builds
**File:** `.github/workflows/dev_build.yaml`
**Triggers:** Schedule (weekdays at 05:00 UTC), manual dispatch
**Purpose:** Automated daily dev builds uploaded to TestFlight for team testing. Tests are allowed to fail (continue-on-error: true) to ensure builds proceed even with test failures.

---

#### `release_build.yaml` - Production Releases
**File:** `.github/workflows/release_build.yaml`
**Triggers:** Manual dispatch, workflow call
**Purpose:** Builds production releases for App Store submission with production configurations and stricter quality checks.

---

#### `ipa.yaml` - IPA Build
**File:** `.github/workflows/ipa.yaml`
**Triggers:** Manual dispatch, repository dispatch (triggers test run repository after build)
**Purpose:** Builds IPA file for the application. After successful build, triggers automated tests in the anytype-test repository.
**Purpose:** Builds IPA file for the application. Invoked from the test run repository for automated testing.

---

### Automation Workflows

#### `automerge.yaml` - Automatic PR Merge
**File:** `.github/workflows/automerge.yaml`
**Triggers:** `pull_request_target` events
**Purpose:** Automatically approves and merges PRs created by the `any-association` account. Only runs when `github.actor == 'any-association'`, enables auto-merge with squash strategy after approval. PR will merge automatically once all required checks pass.
**Use cases:** Automated dependency updates, middleware updates, and other bot-generated PRs.

---

#### `update_middleware.yaml` - Middleware Version Update
**File:** `.github/workflows/update_middleware.yaml`
**Triggers:** Manual dispatch with inputs, workflow call (reusable)
**Purpose:** Updates the middleware version, creates a PR, and optionally closes the Linear issue.

**Inputs:**
- `middle_version` (required) - Middleware version (e.g., "v0.44.0")
- `task_name` (optional) - Linear task ID (e.g., "IOS-5140") for branch naming and issue closing

**Process:** Checks current version in Libraryfile → Updates version if different → Downloads binaries → Regenerates protobuf → Runs tests → Creates PR → Closes Linear issue (if task_name provided)

**Branch naming:**
- With task: `IOS-5140-update-middleware-v0.44.0`
- Without task: `update-middleware-v0.44.0`

**Important:**
- PRs are created using `SERVICE_USER_GITHUB_TOKEN` (associated with `any-association` account)
- Auto-merge is handled automatically by `automerge.yaml` workflow (no manual intervention needed)
- PR will merge automatically when all required checks pass
- Linear issue is closed when PR is created (not when merged)

---

#### `update_middleware_nightly.yaml` - Nightly Middleware Updates
**File:** `.github/workflows/update_middleware_nightly.yaml`
**Triggers:** Schedule (weekdays at 03:00 UTC), manual dispatch
**Purpose:** Automatically updates to the latest nightly middleware build. Resolves latest nightly version via `Scripts/get-latest-nightly.sh`, then calls `update_middleware.yaml` as a reusable workflow. Sends Slack notification on failure.

---

### Code Quality Workflows

#### `generator_checks.yaml` - Generated Files Validation
**File:** `.github/workflows/generator_checks.yaml`
**Triggers:** Pull requests, manual dispatch
**Purpose:** Ensures all generated files are up-to-date by running `make generate` and checking for modifications. Fails if files are modified, indicating developer forgot to run generators.
**Error message:** "Generated files are not up to date. Please run 'make generate' and commit the changes."
**Why:** Prevents PRs from being merged with stale generated files (localization strings, assets, protobuf, etc.)

---

#### `license-checks.yml` - License Compliance
**File:** `.github/workflows/license-checks.yml`
**Triggers:** Pull requests, manual dispatch
**Purpose:** Validates that all dependencies have approved licenses. Clones `anyproto/open` repository for license definitions and runs Fastlane license check.

---

#### `cla.yml` - Contributor License Agreement
**File:** `.github/workflows/cla.yml`
**Triggers:** Pull requests from external contributors
**Purpose:** Ensures external contributors have signed the CLA.

---

### AI/Code Review Workflows

#### `claude-code-review.yml` - AI Code Review
**File:** `.github/workflows/claude-code-review.yml`
**Triggers:** Pull requests (only on `opened` event)
**Purpose:** Provides AI-powered code review using Claude Code. Reviews are lean and actionable - only reports actual issues (bugs, best practices violations, performance problems, security vulnerabilities), no praise or design suggestions. Can post inline code suggestions using GitHub's suggestion blocks.
**Review status:** ✅ Approved (no issues), ⚠️ Minor Issues (non-critical), 🚨 Major Issues (critical)
**Notable:** Uses CLAUDE.md for project-specific conventions and validates runner/Xcode version mappings.

---

#### `claude.yml` - Claude Integration
**File:** `.github/workflows/claude.yml`
**Triggers:** Various events (project-specific)
**Purpose:** General Claude AI integration for automation tasks.

---

### Utility Workflows

#### `update_cache.yaml` - Cache Management
**File:** `.github/workflows/update_cache.yaml`
**Triggers:** Manual dispatch, scheduled
**Purpose:** Pre-warms GitHub Actions cache for faster builds. Caches local tools, Xcode derived data, and Swift package dependencies.

---

#### `test_fastlane_build.yaml` - Workflow Development Testing
**File:** `.github/workflows/test_fastlane_build.yaml`
**Triggers:** Manual dispatch
**Purpose:** Test workflow used when developing new GitHub workflows. Helps test workflow changes before merging to dev branch.
**Note:** Due to GitHub limitations, new workflow files are not visible in the Actions UI until merged into the dev branch.

---

## Custom Actions

Custom actions are reusable components located in `.github/actions/`. See individual action directories for implementation details.

### `prepare-deps`
**Location:** `.github/actions/prepare-deps`
**Purpose:** Sets up Ruby, Bundler, and Homebrew tools (imagemagick, libgit2)
**Used by:** Nearly all workflows that need build dependencies

---

### `update-git-config`
**Location:** `.github/actions/update-git-config`
**Purpose:** Configures git user for automated commits
**Used by:** Workflows that create commits (branch_build, dev_build, update_middleware)

---

### `send-slack-message`
**Location:** `.github/actions/send-slack-message`
**Purpose:** Sends Slack direct messages to workflow initiators based on job status
**Inputs:** success_message, error_message, status, slack_token, slack_map
**Used by:** branch_build, dev_build, release_build
**Configuration:** Add your GitHub username and work email to `SLACK_MAP` repository variable to receive notifications

---

### `license-checks`
**Location:** `.github/actions/license-checks`
**Purpose:** Validates dependency licenses against approved list from `anyproto/open` repository
**Used by:** license-checks workflow

---

## Auto-merge System

### Overview
The repository uses a **centralized auto-merge system** via the `automerge.yaml` workflow. Any PR created by the `any-association` account is automatically approved and merged when all checks pass.

### How It Works

#### `automerge.yaml` Workflow
- **Trigger:** All PRs (via `pull_request_target`)
- **Condition:** Only runs if `github.actor == 'any-association'`
- **Actions:**
  1. Auto-approves the PR
  2. Enables auto-merge with `--squash` strategy
  3. PR merges automatically when all required checks pass

#### What Gets Auto-merged
- All PRs from the `any-association` account, including:
  - Automated dependency updates
  - Middleware updates (via `update_middleware.yaml`)
  - Other bot-generated changes
- Individual workflows don't need explicit auto-merge steps - it's handled centrally

#### What Does NOT Get Auto-merged
- PRs from human developers
- PRs from other bot accounts

### Configuration

**For automated workflows:**
- Use `SERVICE_USER_GITHUB_TOKEN` to create PRs (associated with `any-association` account)
- The `automerge.yaml` workflow handles approval and auto-merge automatically
- No need to include auto-merge steps in individual workflow files

**For manual PRs:**
- Create PR using your own account or other tokens
- PR will require manual review and merge

---

## Required Secrets & Variables

### Secrets

| Secret | Purpose | Used By |
|--------|---------|---------|
| `SERVICE_USER_GITHUB_TOKEN` | GitHub token for creating PRs and pushing changes | update_middleware, generator_checks |
| `MIDDLEWARE_TOKEN` | Token for accessing middleware repository | All workflows that download middleware |
| `LINEAR_TOKEN` | Linear API token for closing issues | update_middleware, branch_build |
| `SSH_ACCESS_KEY` | SSH key for accessing private repositories | branch_build, dev_build, release_build |
| `SSH_KEY_FASTLANE_MATCH` | SSH key for Fastlane Match (code signing) | All build workflows |
| `MATCH_PASSWORD` | Password for Fastlane Match encryption | All build workflows |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API key ID | All build workflows |
| `APP_STORE_CONNECT_API_ISSUER_ID` | App Store Connect API issuer ID | All build workflows |
| `APP_STORE_CONNECT_API_PRIVATE_KEY` | App Store Connect API private key | All build workflows |
| `SENTRY_AUTH_TOKEN` | Sentry authentication token for crash reporting | All build workflows |
| `SENTRY_DSN` | Sentry DSN for crash reporting | All build workflows |
| `AMPLITUDE_API_KEY` | Amplitude analytics API key | All build workflows |
| `SLACK_BOT_TOKEN` | Slack bot token for notifications | send-slack-message action |
| `SLACK_URL_BUILD_TESTS` | Slack webhook for build/test notifications | update_middleware_nightly |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth token for Claude Code API access | claude-code-review |

### Variables

| Variable | Purpose | Used By |
|----------|---------|---------|
| `SLACK_MAP` | JSON mapping of GitHub usernames to work emails | send-slack-message action |

**Example SLACK_MAP:**
```json
{
  "githubUsername1": "user1@anytype.io",
  "githubUsername2": "user2@anytype.io"
}
```

---

## Runner Configuration

### Available Runners

| Runner | Xcode Version | Use Case |
|--------|--------------|----------|
| `macos-15` | Xcode 15.x (e.g., 15.4) | Legacy builds, older Xcode requirements |
| `macos-26` | Xcode 26.0 | **Current standard** - All modern builds |
| `ubuntu-latest` | N/A | Utility jobs, scripts, API calls |

### Runner-Xcode Version Mapping

**Critical rule:** The `xcode-version` in `setup-xcode` must match the capabilities of the `runs-on` runner.

**Current standard configuration:**
```yaml
jobs:
  build:
    runs-on: macos-26
    steps:
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1.6.0
        with:
          xcode-version: '26.0'
```

### Reference Documentation
- [macos-15 Readme](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md)
- [macos-26 ARM64 Readme](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-arm64-Readme.md)
- [All Runner Images](https://github.com/actions/runner-images/tree/main/images/macos)

**Note:** Claude Code Review workflow validates runner/Xcode version mappings in PRs.

---

## Best Practices

### When to Use Which Workflow

**For development:**
- **Local changes:** Use `make generate` and test locally
- **PR testing:** `pr_tests.yml` runs automatically
- **Quick TestFlight build:** Use `branch_build.yaml` manually

**For middleware updates:**
- **Manual version update:** Use `update_middleware.yaml` with specific version
- **Latest nightly:** Let `update_middleware_nightly.yaml` run automatically, or trigger manually
- **Auto-merge:** PRs are automatically merged by `automerge.yaml` when all checks pass
- **Note:** Tests passing is required for merge, but doesn't guarantee full compatibility - monitor for issues

**For releases:**
- Use `release_build.yaml` for production builds
- Ensure all tests pass and code review is complete

### Modifying Workflows Safely

1. **Test locally first:**
   ```bash
   # Validate YAML syntax
   cat .github/workflows/your-workflow.yaml | ruby -ryaml -e "YAML.load(STDIN.read)"
   ```

2. **Use small, incremental changes:**
   - Modify one workflow at a time
   - Test with `workflow_dispatch` trigger
   - Review workflow run logs carefully

3. **Understand dependencies:**
   - Check if workflow calls other workflows
   - Verify secrets and variables are available
   - Ensure runner has necessary tools

4. **For runner/Xcode changes:**
   - Verify compatibility: [Runner Images Documentation](https://github.com/actions/runner-images)
   - Update both `runs-on` and `xcode-version` together
   - Test build workflow after changes

5. **Update this documentation:**
   - When adding new workflows, document them here
   - When changing behavior, update relevant sections
   - When adding secrets, document their purpose

### Common Issues and Solutions

**Issue:** Generated files check fails on PR
- **Solution:** Run `make generate` locally and commit changes

**Issue:** Middleware update PR created but tests fail
- **Solution:** PR will not auto-merge until tests pass. Review the failures and push fixes to the PR branch. Once tests pass, auto-merge will proceed automatically.

**Issue:** Workflow run fails with "Resource not accessible by integration"
- **Solution:** Check `permissions:` block in workflow, ensure necessary permissions are granted

**Issue:** Slack notifications not received
- **Solution:** Add your GitHub username and email to `SLACK_MAP` repository variable

**Issue:** Auto-merge not working
- **Solution:** Verify PR is from `any-association` account and all required checks pass

---

## Maintenance

### Regular Tasks

**Weekly:**
- Review failed workflow runs
- Check for outdated action versions

**Monthly:**
- Review and update runner versions if needed
- Audit secrets for expiration
- Review auto-merge behavior

**Quarterly:**
- Update third-party actions to latest versions
- Review and optimize workflow performance
- Update this documentation

### Getting Help

- **Workflow failures:** Check workflow run logs in GitHub Actions tab
- **Runner issues:** Consult [GitHub Actions Runner Images](https://github.com/actions/runner-images)
- **Fastlane issues:** Check `fastlane/Fastfile` and Fastlane documentation
- **Xcode issues:** Verify Xcode version compatibility with runner

---

**Last Updated:** 2025-10-29
**Maintainers:** iOS Team
