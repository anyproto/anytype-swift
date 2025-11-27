# Anytype iOS App

## Overview
Anytype is a privacy-focused, local-first workspace application for iOS. Built with Swift and SwiftUI, it provides users with a secure environment for creating and organizing their digital content including notes, tasks, and documents. The app uses a custom middleware for data synchronization and storage.

## 🚀 Quick Start

### ⚠️ CRITICAL RULES - NEVER VIOLATE
1. **NEVER commit changes without explicit user request** - Always wait for user to explicitly ask you to commit
2. **NEVER stage files without explicit user request** - Always wait for user to explicitly ask you to stage files with `git add`
3. **NEVER add AI signatures to commits** - No "Co-Authored-By: Claude <noreply@anthropic.com>"
4. **NEVER add AI signatures to PRs** - No "🤖 Generated with Claude Code"
5. **NEVER add any form of AI attribution** anywhere in the codebase

### Development Setup
1. **First-time setup** (run in order):
   ```bash
   make setup-env      # Set up environment configuration
   make setup-tools    # Install required development tools
   make setup-middle   # Download and configure middleware dependencies
   ```

2. **Requirements**:
   - Xcode 16.1 or later
   - Swift Package Manager (built-in)
   - If Dependencies/Middleware/Lib.xcframework is missing binaries, try `make generate`

### Compilation Verification
After making code changes, report them to the user who will verify compilation in Xcode (faster with caches).

### Essential Commands
```bash
make generate        # Run all code generators (sourcery, assets, localization)
make generate-middle # Regenerate middleware and protobuf files (when needed)
make setup-middle    # Initial setup
```

## 🎯 Core Guidelines

### AI Assistance
- **Always present a detailed action plan before implementing multi-step changes and await approval before proceeding**
- **When code review is approved**: Proceed directly with push and PR creation without asking for confirmation

### 📚 Skills System & Documentation (Progressive Disclosure)

**Level 1 - This File**: Quick start, critical rules, high-level overview
**Level 2 - Skills**: Context-aware guides that auto-activate → `.claude/skills/`
**Level 3 - Specialized Docs**: Deep knowledge for specific domains

#### Auto-Activating Skills

The skills system provides context-aware guidance that auto-activates based on your work:
- **ios-dev-guidelines** → Auto-activates when working with `.swift` files
- **localization-developer** → Auto-activates for localization work
- **code-generation-developer** → Auto-activates for code generation
- **design-system-developer** → Auto-activates for UI/design work
- **code-review-developer** → Auto-activates when reviewing PRs or code changes
- **analytics-developer** → Auto-activates for analytics events and route tracking
- **feature-toggle-developer** → Auto-activates for feature flag removal
- **skills-manager** → Auto-activates for skill system management

**How it works**: When you start a task, the system analyzes your prompt and file context, then automatically suggests relevant skills. No manual loading needed.

**🚨 CRITICAL: Claude Must Actively Use Skills**

The hook system only **suggests** skills - it does NOT auto-load them. When you (Claude) see skill suggestions in system reminders, you MUST:

1. **📚 When you see "Relevant Skill: X"**:
   - IMMEDIATELY read `.claude/skills/X/SKILL.md`
   - Apply the patterns and rules from that skill
   - Don't just acknowledge - actively use the skill's guidance

2. **💡 When you see "NO SKILLS ACTIVATED"**:
   - ASK the user: "Should the [skill-name] skill have activated for this task?"
   - If yes, run: `.claude/hooks/utils/extract-keywords.sh "user's prompt"`
   - Then run: `.claude/hooks/utils/add-keywords-to-skill.sh <skill-name> <keywords>`
   - This teaches the system for future prompts

3. **🎯 Be Proactive**:
   - Notice skill suggestions in EVERY system reminder
   - Read suggested skills even if you think you know the answer
   - Skills contain critical, project-specific patterns you must follow

**Example Flow**:
```
User: "Add analytics to track button clicks"
System: 📚 Relevant Skill: analytics-developer
Claude: [Reads .claude/skills/analytics-developer/SKILL.md]
Claude: [Follows the patterns in that skill]
```

**Why This Matters**:
- Skills contain CRITICAL project-specific rules (e.g., "NEVER hardcode strings")
- Each instance of Claude needs to learn from skills, not just general knowledge
- The skill system enables consistent behavior across all Claude instances

**Auto-learning**: When the system fails to activate a skill for a substantial prompt (100+ chars or 3+ lines):
1. You'll be prompted with available skills
2. If you identify which skill should have activated, tell Claude
3. Claude extracts relevant keywords from your prompt
4. Keywords are automatically added to skill-rules.json
5. Future similar prompts will auto-activate the skill

**Manual keyword management**:
```bash
# Extract keywords from a prompt
.claude/hooks/utils/extract-keywords.sh "your prompt text"

# Add keywords to a skill
.claude/hooks/utils/add-keywords-to-skill.sh <skill-name> <keyword1> [keyword2] ...

# Example
.claude/hooks/utils/add-keywords-to-skill.sh localization-developer "membership" "tiers"
```

**Learn more**: See `.claude/skills/README.md` for system overview and `.claude/hooks/README.md` for automation details.

#### Specialized Documentation

For deep knowledge, see these guides:

| Topic | Quick Reference (Skills) | Complete Guide (Specialized Docs) |
|-------|-------------------------|-----------------------------------|
| **iOS Development** | `.claude/skills/ios-dev-guidelines/` | `Anytype/Sources/IOS_DEVELOPMENT_GUIDE.md` |
| **Localization** | `.claude/skills/localization-developer/` | `Anytype/Sources/PresentationLayer/Common/LOCALIZATION_GUIDE.md` |
| **Code Generation** | `.claude/skills/code-generation-developer/` | `Modules/AnytypeCore/CODE_GENERATION_GUIDE.md` |
| **Design System** | `.claude/skills/design-system-developer/` | `Anytype/Sources/PresentationLayer/Common/DESIGN_SYSTEM_MAPPING.md` |
| **Typography** | `.claude/skills/design-system-developer/` | `Anytype/Sources/PresentationLayer/Common/TYPOGRAPHY_MAPPING.md` |
| **Code Review** | `.claude/skills/code-review-developer/` | `.claude/CODE_REVIEW_GUIDE.md` |

### Code Quality
- **Never edit files marked with `// Generated using Sourcery/SwiftGen`** - These are automatically generated
- **Never use hardcoded strings in UI** - Always use localization constants (see LOCALIZATION_GUIDE.md)
- **All user-facing text must be localized** for international support
- **Do not add comments** unless explicitly requested
- **We only work in feature branches** - never push directly to develop/main
- **Remove unused code after refactoring** - Delete unused properties, functions, and entire files that are no longer referenced
- **Always update tests and mocks when refactoring** - When renaming classes, properties, or dependencies, search for and update all references in:
  - Unit tests (`AnyTypeTests/`)
  - Preview mocks (`Anytype/Sources/PreviewMocks/`)
  - Mock implementations (`Anytype/Sources/PreviewMocks/Mocks/`)
  - Dependency injection registrations (`MockView.swift`, test setup files)

## 📝 Localization System (Quick Reference)

**Full Guide**: `Anytype/Sources/PresentationLayer/Common/LOCALIZATION_GUIDE.md`

### Quick Workflow
1. Search existing: `rg "yourSearchTerm" Modules/Loc/Sources/Loc/Generated/Strings.swift`
2. Choose file: Auth (86 keys), Workspace (493 keys), or UI (667 keys)
3. Add to appropriate `.xcstrings` file if missing
4. Run: `make generate`
5. Use: `Loc.yourKey` or `AnytypeText(Loc.yourKey, style: .uxBodyRegular)`

### Critical Rules
- ❌ Never use hardcoded strings
- ❌ Never use `String(format: Loc.key, value)` → ✅ Use `Loc.key(value)`
- ⚠️ Keys must be unique across ALL 3 .xcstrings files
- ⚠️ Only edit English (`en`) - Crowdin handles other languages

## 🎨 Design System (Quick Reference)

**Full Guides**:
- `Anytype/Sources/PresentationLayer/Common/DESIGN_SYSTEM_MAPPING.md`
- `Anytype/Sources/PresentationLayer/Common/TYPOGRAPHY_MAPPING.md`

### Icons
Icons organized by size (x18, x24, x32, x40):
```swift
Image(asset: .X32.qrCode)    // 32pt icon
Image(asset: .X24.search)    // 24pt icon
```

**Adding**: Export SVG from Figma → Add to Assets.xcassets → `make generate` → Use constant

### Typography
Figma styles map to Swift constants:
```swift
AnytypeText("Title", style: .uxTitle1Semibold)  // Screen titles
AnytypeText("Body", style: .bodyRegular)         // Body text
```

### Colors
Always use design system constants:
```swift
.foregroundColor(Color.Text.primary)
.background(Color.Shape.transparentSecondary)
```

## 🔧 Code Generation (Quick Reference)

**Full Guide**: `Modules/AnytypeCore/CODE_GENERATION_GUIDE.md`

### Quick Workflow
```bash
make generate        # After adding flags, assets, or localization
make generate-middle # After middleware/protobuf changes
```

### Feature Flags
1. Add to `/Modules/AnytypeCore/.../FeatureDescription+Flags.swift`
2. Run `make generate`
3. Use: `if FeatureFlags.yourFlag { ... }`

### Tools
- **SwiftGen**: Assets & localization → type-safe constants
- **Sourcery**: Swift code from templates → boilerplate reduction
- **Protobuf**: Middleware message generation

## 🏗️ Architecture (High-Level)

**Full Guide**: `Anytype/Sources/IOS_DEVELOPMENT_GUIDE.md`

### Technologies
- **Swift & SwiftUI** - Primary language and UI framework
- **Combine** - Reactive programming
- **Factory** - Dependency injection
- **Middleware** - Custom binary framework (Protobuf communication)

### Project Structure
```
Anytype/Sources/
├── ApplicationLayer/    # App lifecycle, coordinators
├── PresentationLayer/   # UI components, ViewModels
├── ServiceLayer/        # Business logic, data services
├── Models/             # Data models, entities
└── CoreLayer/          # Core utilities, networking

Modules/                # Swift packages
├── AnytypeCore/        # Core utilities, feature flags
├── Loc/                # Localization
├── Assets/             # Design assets
└── Services/           # Core services
```

### Key Patterns
- **MVVM**: ViewModels handle business logic, Views are lightweight
- **Coordinator**: Navigation handled by coordinators
- **Repository**: Data access abstracted through services
- **Dependency Injection**: Factory pattern with `@Injected`

## 🔧 Code Style (Quick Reference)

**Full Guide**: `Anytype/Sources/IOS_DEVELOPMENT_GUIDE.md`

### Formatting
- 4 spaces indentation (no tabs)
- K&R style (opening brackets on same line)
- 120-140 character lines
- **NEVER trim whitespace-only lines** - Preserve blank lines with spaces/tabs exactly

### Naming
- **PascalCase**: Classes, Structs, Protocols (`ChatViewModel`)
- **camelCase**: Variables, Functions (`objectDetails`, `updateRows()`)
- **Extensions**: `TypeName+Feature.swift`

### Swift Best Practices
- Use `@MainActor` for UI classes
- Prefer `guard` for early returns
- Use async/await over completion handlers
- Avoid nested types (extract to top-level)
- Use explicit switch for enums (enables compiler warnings)

## 🔄 Development Workflow

### 🚨 Pre-Commit Checklist
**ONLY WHEN USER EXPLICITLY ASKS YOU TO STAGE OR COMMIT** - STOP and verify:
- [ ] User has explicitly requested staging files (`git add`) or committing
- [ ] User has explicitly requested a commit
- [ ] NO "Co-Authored-By: Claude" in commit message
- [ ] NO "Generated with Claude" or similar AI signatures
- [ ] NO emoji signatures like 🤖
- [ ] Single line commit message only
- [ ] Professional message without AI attribution

### Task-Based Branching
**⚠️ CRITICAL: This is the FIRST thing to do when starting any task**

When receiving a Linear task ID (e.g., `IOS-5292`):
1. **Fetch the Linear issue**: Use `mcp__linear__list_issues` with the task ID to get issue details
2. **Get the branch name**: Extract `gitBranchName` field from the Linear issue (format: `ios-XXXX-description`)
3. **Switch to the task branch IMMEDIATELY**: `git checkout ios-5292-update-space-hub-loading-state`

**All work for the task must be done in this dedicated branch**

**Example**:
```bash
# Fetch issue details
mcp__linear__list_issues(query: "IOS-5292", limit: 1)
# Response includes: "gitBranchName": "ios-5292-update-space-hub-loading-state"

# Use the exact branch name from Linear
git checkout ios-5292-update-space-hub-loading-state
```

### Git & GitHub
- **Main branch**: `develop`
- **Feature branches**: `ios-XXXX-description`
- **⚠️ CRITICAL: NEVER commit without explicit user request**
- **Commit messages**: Single line, no AI signatures
- **GitHub CLI**: Use `gh` tool for all GitHub operations
  - `gh pr view <PR_NUMBER> --repo anyproto/anytype-swift`
  - `gh pr diff <PR_NUMBER> --repo anyproto/anytype-swift`

### GitHub Workflows & Actions
For comprehensive documentation on GitHub workflows, actions, and automation (including auto-merge behavior), see `.github/WORKFLOWS_REFERENCE.md`

### Release Branch Workflow
When creating a branch from a release branch (e.g., `release/0.42.0`):
- Target the **release branch** in your PR, not `develop`
- Always add the **"Release"** label to the PR
- Example: `gh pr create --base release/0.42.0 --label "Release" --title "..." --body "..."`

### ❌ FORBIDDEN Git Practices

**ABSOLUTELY NEVER run destructive git operations** unless you have explicit, written approval:
- `git reset --hard` - Discards all local changes permanently
- `git checkout <old-commit>` or `git restore` to revert to older commits
- `git clean -fd` - Removes untracked files permanently
- `git push --force` to main/develop - Rewrites shared history

**If you are even slightly unsure about a git command, STOP and ask the user first.**

### Pull Requests
**Format**:
```
## Summary
- Brief description of changes (1-3 bullet points)
```

**Note**: PRs are for programmers, not testers - **NO test plan needed**

**IMPORTANT**:
- **NEVER add AI signatures** like "🤖 Generated with Claude Code" to pull requests
- Keep commits and PRs professional without AI attribution

**Incremental Strategy** (for related changes):
- Sequential branches: `ios-XXXX-description-1`, `ios-XXXX-description-2`
- Chain PRs: `branch-1` → `develop`, `branch-2` → `branch-1`

### 🔧 Git Technical Tips

**Quoting paths with special characters**:
Always quote git paths containing brackets, parentheses, or spaces:
```bash
# ✅ CORRECT
git add "Anytype/Sources/[Feature]/Component.swift"

# ❌ WRONG - Shell interprets brackets as glob
git add Anytype/Sources/[Feature]/Component.swift
```

### Linear Integration
- **Branch management**: See "Task-Based Branching" section above for fetching branch names from Linear
- **Get task context**: Extract task ID from user request or current branch name
- **Check PRs**: Use `gh` tool to examine related PRs
- **Update progress**: Add comments and check off completed items using Linear MCP tools

## 📋 Memories & Tips
- For trivial PRs, add GitHub label "🧠 No brainer" (not in title)
- Use `rg` for searching large files
- Feature flags for all new features
- **NO need to import `Loc` manually** - it's pre-imported by default
- Import `AnytypeCore` for feature flags

## ⚠️ Common Mistakes to Avoid

### Git Operations
**Autonomous Committing (2025-01-28):** Committed changes without explicit user request. NEVER commit unless user explicitly asks. This is a CRITICAL rule.

### File Operations & Architecture
**Wildcard File Deletion (2025-01-24):** Used `rm -f .../PublishingPreview*.swift` - accidentally deleted main UI component. Always check with `ls` first, remove files individually.

### Refactoring & Testing
**Incomplete Mock Updates (2025-01-16):** Refactored properties in production code but forgot to update `MockView.swift` causing test failures. When renaming dependencies:
1. Search for old names: `rg "oldName" --type swift`
2. Update all references in tests, mocks, and DI registrations
3. Report changes to user for compilation verification

---

**Remember**: This file provides quick reference and overview. For detailed guidance, see the specialized documentation guides linked above.