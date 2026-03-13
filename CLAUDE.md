# Anytype iOS App

## Overview
Anytype is a privacy-focused, local-first workspace application for iOS. Built with Swift and SwiftUI, it provides users with a secure environment for creating and organizing their digital content. The app uses a custom middleware for data synchronization and storage.

## ⚠️ CRITICAL RULES - NEVER VIOLATE
1. **NEVER commit/stage without explicit user request** - Wait for user to explicitly ask
2. **NEVER add AI signatures in code** - No AI attribution comments or markers in source files
3. **NEVER run destructive git operations** without explicit approval (`--amend`, `reset --hard`, `push --force`, `clean -fd`)
4. **Always present action plan** before implementing multi-step changes and await approval

## 🔒 Pre-Implementation Gate
When `confidence-check` skill activates, **ALWAYS run the 5-check assessment before writing implementation code**:
```
CONFIDENCE CHECK:
[ ] No duplicates found (25%)
[ ] Follows MVVM/Coordinator/DI patterns (25%)
[ ] Verified existing code/docs (20%)
[ ] Uses Loc/Color/Image design system (15%)
[ ] Root cause understood (15%)

Score: ___% → PROCEED (≥90%) | PAUSE (70-89%) | STOP (<70%)
```
Present results to user. If score <90%, discuss gaps before proceeding.

## 🚀 Quick Start

### Development Setup
```bash
make setup-env      # Set up environment configuration
make setup-tools    # Install required development tools
make setup-middle   # Download and configure middleware dependencies
```

**Requirements**: Xcode 16.1+, Swift Package Manager

### Essential Commands
```bash
make generate        # Run all code generators (sourcery, assets, localization)
make generate-middle # Regenerate middleware and protobuf files
```

### Compilation Verification
After making code changes, report them to the user who will verify compilation in Xcode (faster with caches).

## 📚 Progressive Disclosure System

**Level 1 - This File**: Critical rules, quick start, high-level overview
**Level 2 - Skills**: Context-aware guides in `.claude/skills/` (auto-activate based on work)
**Level 3 - Specialized Docs**: Deep knowledge for specific domains

### Skills (Auto-Activate)
| Skill | Triggers On | Full Guide |
|-------|-------------|------------|
| `ios-dev-guidelines` | `.swift` files | `Anytype/Sources/IOS_DEVELOPMENT_GUIDE.md` |
| `localization-developer` | Localization work | `Anytype/Sources/PresentationLayer/Common/LOCALIZATION_GUIDE.md` |
| `design-system-developer` | UI/design work | `Anytype/Sources/PresentationLayer/Common/DESIGN_SYSTEM_MAPPING.md` |
| `code-generation-developer` | Code generation | `Modules/AnytypeCore/CODE_GENERATION_GUIDE.md` |
| `code-review-developer` | PR reviews | `.claude/CODE_REVIEW_GUIDE.md` |
| `analytics-developer` | Analytics events | Auto-activates |
| `feature-toggle-developer` | Feature flags | Auto-activates |
| `liquid-glass-developer` | iOS 26 glass effects | Auto-activates |
| `swiftui-expert-skill` | SwiftUI expert work | Auto-activates (from AvdLee) |
| `swift-concurrency-developer` | Concurrency/actors | Auto-activates (from Dimillian/Skills + AvdLee) |
| `swiftui-performance-developer` | Performance issues | Auto-activates (from Dimillian/Skills) |
| `swiftui-patterns-developer` | View structure/MV | Auto-activates (from Dimillian/Skills) |
| `confidence-check` | Implementation tasks | Auto-activates (from SuperClaude) |
| `linear-developer` | Linear issues/CLI | `.claude/skills/linear-developer/SKILL.md` |
| `ios-simulator-skill` | Simulator/build/test | `.claude/skills/ios-simulator-skill/SKILL.md` |
| `apple-docs-developer` | Apple API lookup | `.claude/skills/apple-docs-developer/SKILL.md` |

**When you see "Relevant Skill: X"** in system reminders → Read `.claude/skills/X/SKILL.md` and apply its patterns.

**Learn more**: `.claude/skills/README.md`

### Hooks & Skill Activation
- Skills auto-activate based on prompt keywords (see `.claude/hooks/skill-rules.json`)
- Scoring: keywords=2pts, intents=3pts, threshold=3
- Tuning guide: `.claude/skills/skills-manager/SKILL.md`

## 🎯 Core Guidelines

### Code Quality
- **Never edit files marked with `// Generated using Sourcery/SwiftGen`**
- **Never use hardcoded strings in UI** - Use `Loc.yourKey` constants
- **Never push directly to develop/main** - Always use feature branches
- **Remove unused code after refactoring** - Delete unreferenced properties, functions, files
- **Update tests and mocks when refactoring** - Search and update all references in `AnyTypeTests/`, `PreviewMocks/`

### Code Change Principles
- **Read before edit** - Always read the full file/context before making changes
- **Minimize diffs** - Prefer the smallest change that solves the problem
- **Investigate before diagnosing** - Understand the actual issue, don't guess
- **No speculative fallbacks** - Don't add error handling for scenarios that can't happen

### Quick References

@Anytype/Sources/IOS_DEVELOPMENT_GUIDE.md
@Anytype/Sources/PresentationLayer/Common/LOCALIZATION_GUIDE.md
@Anytype/Sources/PresentationLayer/Common/DESIGN_SYSTEM_MAPPING.md
@Modules/AnytypeCore/CODE_GENERATION_GUIDE.md

**Localization** → `Anytype/Sources/PresentationLayer/Common/LOCALIZATION_GUIDE.md`
- Search existing: `rg "term" Modules/Loc/Sources/Loc/Generated/Strings.swift`
- Use `Loc.key(value)` not `String(format: Loc.key, value)`
- Keys unique across all 3 `.xcstrings` files

**Icons** → `Modules/Assets/Sources/Assets/Generated/ImageAsset.swift`
- By size: `Image(asset: .X32.qrCode)`, `Image(asset: .X24.search)`

**Typography** → `Anytype/Sources/PresentationLayer/Common/TYPOGRAPHY_MAPPING.md`

**Colors** → Always use design system: `Color.Text.primary`, `Color.Shape.transparentSecondary`

**Feature Flags** → `Modules/AnytypeCore/.../FeatureDescription+Flags.swift`
- Add flag → `make generate` → Use `FeatureFlags.yourFlag`

## 🏗️ Architecture

**Full Guide**: `Anytype/Sources/IOS_DEVELOPMENT_GUIDE.md`

**Stack**: Swift, SwiftUI, Combine, Factory (DI), Custom Middleware (Protobuf)

**Structure**:
```
Anytype/Sources/
├── ApplicationLayer/    # App lifecycle, coordinators
├── PresentationLayer/   # UI components, ViewModels
├── ServiceLayer/        # Business logic, data services
└── Models/              # Data models, entities

Modules/                 # Swift packages (AnytypeCore, Loc, Assets, Services)
```

**Patterns**: MVVM, Coordinator, Repository, `@Injected` for DI

## 🔄 Git Workflow

### Task-Based Branching
**First thing when starting any task**:
1. Fetch Linear issue: `linctl issue get IOS-XXXX --json`
2. Extract `gitBranchName` field: `| jq -r '.gitBranchName'`
3. Switch immediately: `git checkout <branch-name>`

**linctl reference**: `.claude/skills/linear-developer/SKILL.md` | https://github.com/dorkitude/linctl

### Branches & PRs
- **Main branch**: `develop`
- **Feature branches**: `ios-XXXX-description`
- **Commit messages**: Single line
- **Commit tone**: Direct, technical, no buzzwords. Focus on what changed and why.
- **PR format**: `## Summary` + 1-3 bullet points (no test plan needed)
- **Release branches**: Target release branch in PR, add "Release" label

### GitHub CLI
```bash
gh pr view <PR_NUMBER> --repo anyproto/anytype-swift
gh pr diff <PR_NUMBER> --repo anyproto/anytype-swift
```

**Workflows documentation**: `.github/WORKFLOWS_REFERENCE.md`

### Linear Integration
- Extract task ID from user request or branch name
- Use `gh` tool for related PRs
- Update progress with Linear MCP tools

## 📋 Tips
- For trivial visual/cosmetic PRs only (color changes, spacing tweaks, copy updates), add label "🧠 No brainer". Never use for logic, caching, data flow, or bug fixes.
- Use `rg` for searching large files
- Feature flags for all new features
- `Loc` is pre-imported; import `AnytypeCore` for feature flags
- When stuck after 2-3 attempts, step back and try a different approach

## ⚠️ Common Mistakes

**Autonomous Committing (2025-01-28)**: Committed without explicit user request. NEVER commit unless user explicitly asks.

**Wildcard File Deletion (2025-01-24)**: Used `rm -f .../*.swift` - deleted main UI component. Always check with `ls` first, remove files individually.

**Incomplete Mock Updates (2025-01-16)**: Forgot to update `MockView.swift` after refactoring. When renaming:
1. Search: `rg "oldName" --type swift`
2. Update all references in tests, mocks, DI registrations
3. Report to user for compilation verification

**Over-Engineering (pattern)**: Adding "defensive" code, extra abstractions, or configurability that wasn't requested. Three similar lines > premature abstraction. Only validate at system boundaries.

**Guessing Before Reading (pattern)**: Making assumptions about code behavior without reading it first. Always read the file before suggesting changes.

---

**Remember**: This file is a quick reference. For detailed guidance, read the relevant skill or specialized guide.
