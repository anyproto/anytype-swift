# Anytype iOS App

## Overview
Anytype is a privacy-focused, local-first workspace application for iOS. Built with Swift and SwiftUI, it provides users with a secure environment for creating and organizing their digital content including notes, tasks, and documents. The app uses a custom middleware for data synchronization and storage.

## 🚀 Quick Start

### ⚠️ CRITICAL RULES - NEVER VIOLATE
1. **NEVER add AI signatures to commits** - No "Co-Authored-By: Claude <noreply@anthropic.com>"
2. **NEVER add AI signatures to PRs** - No "🤖 Generated with Claude Code"
3. **NEVER add any form of AI attribution** anywhere in the codebase

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

### Build & Test
```bash
# Normal build
xcodebuild -scheme Anytype -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15' build

# Compilation check
xcodebuild -scheme Anytype -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15' build-for-testing
```

### Essential Commands
```bash
make generate        # Run all code generators (sourcery, assets, localization)
make generate-middle # Regenerate middleware and protobuf files (when needed)
make setup-middle    # Initial setup
```

## 🎯 Core Guidelines

### AI Assistance
- **Always present a detailed action plan before implementing multi-step changes and await approval before proceeding**

### Code Quality
- **Never edit files marked with `// Generated using Sourcery/SwiftGen`** - These are automatically generated
- **Never use hardcoded strings in UI** - Always use localization constants
- **All user-facing text must be localized** for international support
- **Do not add comments** unless explicitly requested
- **We only work in feature branches** - never push directly to develop/main
- **Remove unused code after refactoring** - Delete unused properties, functions, and entire files that are no longer referenced
- **Always update tests and mocks when refactoring** - When renaming classes, properties, or dependencies, search for and update all references in:
  - Unit tests (`AnyTypeTests/`)
  - Preview mocks (`Anytype/Sources/PreviewMocks/`)
  - Mock implementations (`Anytype/Sources/PreviewMocks/Mocks/`)
  - Dependency injection registrations (`MockView.swift`, test setup files)

## 📝 Localization System

### Quick Workflow
1. **Search existing keys first**:
   ```bash
   rg "yourSearchTerm" Modules/Loc/Sources/Loc/Generated/Strings.swift
   ```

2. **Use existing patterns**:
   - Block titles: `[feature]BlockTitle`
   - Block subtitles: `[feature]BlockSubtitle`
   - Common words: `camera`, `photo`, `picture`, `video(1)`

3. **Choosing the Right File**:
   Localization is split into 3 files - select based on your feature:
   - **Auth.xcstrings** (86 keys): Authentication, login/join flows, keychain, vault, onboarding, migration
   - **Workspace.xcstrings** (493 keys): Spaces, objects, relations, collections, sets, types, templates, collaboration
   - **UI.xcstrings** (667 keys): Settings, widgets, alerts, common UI elements, general app strings

   **⚠️ CRITICAL**: Keys must be unique across ALL three files. Duplicate keys will break code generation.

4. **Only if key doesn't exist**, add to the appropriate file in `Modules/Loc/Sources/Loc/Resources/`:
   ```json
   "Your localization key" : {
     "extractionState" : "manual",
     "localizations" : {
       "en" : {
         "stringUnit" : {
           "state" : "translated",
           "value" : "Your English text here"
         }
       }
     }
   }
   ```

5. **Generate and use**:
   ```bash
   make generate
   ```
   ```swift
   import Loc
   AnytypeText(Loc.yourLocalizationKey, style: .uxCalloutMedium)
   ```

### Key Patterns
- **Naming**: Use short, descriptive keys → `"No properties yet"` ✅, `"No properties yet. Add some to this type."` ❌
- **Hierarchical**: Use dots for organization → `"QR.join.title"` creates `Loc.Qr.Join.title`
- **Generated file**: All 3 localization files (Auth, Workspace, UI) generate into a single `Strings.swift` file (~5,000 lines). Use `rg` for searching
- **Always import**: `import Loc` when using localization

### Dynamic Localization (with Parameters)

**✅ CORRECT** - Generated function with parameters:
```swift
// For string: "You've reached the limit of %lld editors"
Loc.SpaceLimit.Editors.title(4)  // Proper way

// For string: "Pin limit reached: %d pinned spaces"
Loc.pinLimitReached(10)  // Proper way
```

**❌ WRONG** - Never use String(format:):
```swift
String(format: Loc.SpaceLimit.Editors.title, 4)  // DON'T DO THIS
String(format: Loc.pinLimitReached, 10)  // DON'T DO THIS
```

**Why**: SwiftGen automatically generates parameterized functions for strings with format specifiers (%lld, %d, %@). Always use the generated function directly.

## 🎨 Design System & Common UI Components

### Quick Reference
- **Search Patterns**: `/PresentationLayer/Common/SwiftUI/Search/SEARCH_PATTERNS.md`
- **Design System Mapping**: `/PresentationLayer/Common/DESIGN_SYSTEM_MAPPING.md`
- **Analytics Patterns**: `/PresentationLayer/Common/Analytics/ANALYTICS_PATTERNS.md`

### Icons
Icons are code-generated from assets organized by size (x18, x24, x32, x40).

**Usage**:
```swift
Image(asset: .X32.qrCode)    // 32pt QR code icon
Image(asset: .X24.search)    // 24pt search icon
```

**Adding new icons**:
1. Export SVG from Figma ("32/qr code" format)
2. Add to `/Modules/Assets/.../Assets.xcassets/DesignSystem/x32/QRCode.imageset/`
3. Run `make generate`
4. Use: `Image(asset: .X32.qrCode)`

### Feature Flags
Wrap new features in boolean toggles for safe rollouts.

**Adding**:
1. Edit `/Modules/AnytypeCore/AnytypeCore/Utils/FeatureFlags/FeatureDescription+Flags.swift`:
   ```swift
   static let yourFeatureName = FeatureDescription(
       title: "Your Feature Name",
       type: .feature(author: "Your Name", releaseVersion: "X.X.X"),
       defaultValue: false,
       debugValue: true
   )
   ```

2. Generate: `make generate`

3. Use:
   ```swift
   import AnytypeCore
   
   if FeatureFlags.yourFeatureName {
       // Your feature code
   }
   ```

**Types**: `.debug` (debug-only), `.feature(author:releaseVersion:)` (production)

## 🏗️ Architecture

### Technologies
- **Swift & SwiftUI** - Primary language and UI framework
- **Combine** - Reactive programming
- **Factory** - Dependency injection
- **Middleware** - Custom binary framework for core functionality
- **Protobuf** - Middleware communication

### Structure
```
Anytype/Sources/
├── ApplicationLayer/    # App lifecycle, coordinators
├── PresentationLayer/   # UI components, ViewModels
├── ServiceLayer/        # Business logic, data services
├── Models/             # Data models, entities
├── CoreLayer/          # Core utilities, networking
└── DesignSystem/       # Reusable UI components

Modules/                # Swift packages
├── Services/           # Core services
├── AnytypeCore/        # Core utilities
├── ProtobufMessages/   # Generated protobuf code
└── ...
```

### Key Patterns
- **MVVM**: ViewModels handle business logic for SwiftUI views
- **Coordinator**: Navigation handled by coordinators
- **Repository**: Data access abstracted through services
- **Protocol-Oriented**: Heavy use of protocols for testability
- **Dependency Injection**: Factory pattern in `ServiceLayer/ServicesDI.swift`

## 🔧 Code Style

### Formatting
- 4 spaces indentation (no tabs)
- K&R style (opening brackets on same line)
- 120-140 character lines
- One blank line between functions, two between sections

### Naming
- **PascalCase**: Classes, Structs, Protocols (`ChatViewModel`)
- **camelCase**: Variables, Functions (`objectDetails`, `updateRows()`)
- **Extensions**: `TypeName+Feature.swift`
- **Protocols**: Often suffixed with `Protocol`

### Swift Best Practices
- Prefer `guard` for early returns
- Use `@MainActor` for UI classes
- Import order: system → third-party → internal
- Property organization: @Published/@Injected → public → private → constants → variables → methods
- Use async/await, SwiftUI property wrappers, trailing closures, type inference
- **Avoid nested types** - Extract enums/structs to top-level with descriptive names (e.g., `SpaceLimitBannerLimitType` instead of `SpaceLimitBannerView.LimitType`)

## 🔄 Development Workflow

### 🚨 Pre-Commit Checklist
**STOP** before EVERY commit and verify:
- [ ] NO "Co-Authored-By: Claude" in commit message
- [ ] NO "Generated with Claude" or similar AI signatures
- [ ] NO emoji signatures like 🤖
- [ ] Single line commit message only
- [ ] Professional message without AI attribution

### Task-Based Branching
**⚠️ CRITICAL: This is the FIRST thing to do when starting any task**

When receiving a Linear task ID (e.g., `IOS-5292`):
1. **Identify the task branch**: The branch name follows the format `ios-XXXX-description`
   - Example: `ios-5292-update-space-hub-loading-state`
   - You can retrieve the branch name from Linear issue details

2. **Switch to the task branch IMMEDIATELY** before doing ANY other work:
   ```bash
   git checkout ios-5292-update-space-hub-loading-state
   ```

3. **All work for the task must be done in this dedicated branch**
   - Never work on tasks in the wrong branch
   - Verify you're on the correct branch: `git branch --show-current`

### Git & GitHub
- **Main branch**: `develop`
- **Feature branches**: `ios-XXXX-description`
- **Commit messages**: 
  - Single line only
  - **NO AI signatures** (no "Generated with Claude", no co-author attribution)
  - Professional and concise
- **GitHub CLI**: Use `gh` tool for all GitHub operations
  - `gh pr view <PR_NUMBER> --repo anyproto/anytype-swift`
  - `gh pr diff <PR_NUMBER> --repo anyproto/anytype-swift`

### Release Branch Workflow
- **Branches from release**: When creating a branch from a release branch (e.g., `release/0.42.0`):
  - Target the **release branch** in your PR, not `develop`
  - Always add the **"Release"** label to the PR
  - Example: `gh pr create --base release/0.42.0 --label "Release" --title "..." --body "..."`

### ❌ FORBIDDEN Git Practices

**NEVER do this:**
```bash
# ❌ WRONG - Contains AI attribution
git commit -m "Fix pinned spaces limit

Co-Authored-By: Claude <noreply@anthropic.com>"

# ❌ WRONG - Contains AI signature
git commit -m "Add feature 🤖 Generated with Claude Code"
```

**ALWAYS do this:**
```bash
# ✅ CORRECT - Clean, professional, single line
git commit -m "IOS-4852 Add limit check for pinned spaces"
```

### Pull Requests
**Format**:
```
## Summary
- Brief description of changes (1-3 bullet points)
```

**Note**: PRs are for programmers, not testers - **NO test plan needed**

**IMPORTANT**: 
- **NEVER add AI signatures** like "🤖 Generated with Claude Code" to pull requests
- **NEVER add AI signatures** to commit messages
- Keep commits and PRs professional without AI attribution

**Incremental Strategy** (for related changes):
- Sequential branches: `ios-XXXX-description-1`, `ios-XXXX-description-2`
- Chain PRs: `branch-1` → `develop`, `branch-2` → `branch-1`
- Atomic changes per branch

### Linear Integration
1. **Get task context**: Extract task number from branch name or ask user
2. **Fetch details**: Use Linear MCP tools (`mcp__linear__get_issue`)
3. **Check PRs**: Use `gh` tool to examine related PRs
4. **Update progress**: Add comments and check off completed items

## 🛠️ Code Generation

### Tools & Locations
- **SwiftGen**: Assets, localization strings (`/Modules/*/swiftgen.yml`)
- **Sourcery**: Swift code from templates (`/Modules/*/sourcery.yml`)
- **Custom**: Protobuf splitting (`anytypeGen.yml`)

### Important Notes
- Generated files marked with `// Generated using Sourcery/SwiftGen`
- Never edit generated files directly
- Update source templates/configurations instead
- Always run `make generate` after template changes

## 📚 Common Tasks

### Adding Features
1. Create models in `Models/` (if needed)
2. Add service logic in `ServiceLayer/`
3. Create ViewModel in `PresentationLayer/`
4. Build UI with SwiftUI
5. Add tests in `AnyTypeTests/`
6. Wrap in feature flags

### Working with Middleware
- Pre-compiled binary framework
- Communication via Protobuf messages
- Message definitions in `Modules/ProtobufMessages/`

## 📋 Memories & Tips
- For trivial PRs, add GitHub label "🧠 No brainer" (not in title)
- Use `rg` for searching large files
- Check existing keys before adding new localization
- Feature flags for all new features
- **NO need to import `Loc` manually** - it's pre-imported by default in shared header
- Import `AnytypeCore` for feature flags

### ⚠️ Common Mistakes to Avoid

#### File Operations & Architecture
**Wildcard File Deletion (2025-01-24):** Used `rm -f .../PublishingPreview*.swift` - accidentally deleted main UI component. Always check with `ls` first, remove files individually, keep UI in PresentationLayer.

#### Refactoring & Testing
**Incomplete Mock Updates (2025-01-16):** Refactored `spaceViewStorage` → `spaceViewsStorage` and `participantSpaceStorage` → `participantSpacesStorage` in production code, but forgot to update `MockView.swift` causing test failures. When renaming dependencies:
1. Search for old names across entire codebase: `rg "oldName" --type swift`
2. Update all references in tests, mocks, and DI registrations
3. Run unit tests to verify: `xcodebuild -scheme Anytype -destination 'platform=iOS Simulator,name=iPhone 15' build-for-testing`