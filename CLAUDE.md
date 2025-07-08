# Anytype iOS app

## Overview
Anytype is a privacy-focused, local-first workspace application for iOS. Built with Swift and SwiftUI, it provides users with a secure environment for creating and organizing their digital content including notes, tasks, and documents. The app uses a custom middleware for data synchronization and storage.

## Development Setup

### First-Time Setup
When setting up the project for the first time, run these commands in order:
1. `make setup-env` - Set up environment configuration
2. `make setup-tools` - Install required development tools
3. `make setup-middle` - Download and configure middleware dependencies

### Additional Setup Notes
- If Dependencies/Middleware/Lib.xcframework is missing binaries, try `make generate`
- Use Xcode 16.1 or later for development
- The project uses Swift Package Manager for dependency management

## Building and Testing
- **For compilation check**: `xcodebuild -scheme Anytype -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15' build-for-testing`
- **Normal build**: `xcodebuild -scheme Anytype -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 15' build`

## Important Guidelines

### AI Assistance Guidelines
- **Always present a detailed action plan before implementing multi-step changes and await approval before proceeding**

### Generated Files
- **Never edit files marked with `// Generated using Sourcery/SwiftGen`**
- These files are automatically generated and will be overwritten

### Localization
- **Never use hardcoded strings in UI** - Always use localization constants
- **IMPORTANT**: All user-facing text must be localized for international support

#### Adding New Localized Strings
1. **Add to Localizable.xcstrings**: Edit `Modules/Loc/Sources/Loc/Resources/Localizable.xcstrings`
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

2. **Use short, descriptive keys**: 
   - ✅ Good: `"No properties yet"`
   - ❌ Bad: `"No properties yet. Add some to this type."`

3. **Generate constants**: Run `make generate-middle` to update `Modules/Loc/Sources/Loc/Generated/Strings.swift`

4. **Use in code**: 
   ```swift
   import Loc
   
   AnytypeText(Loc.noPropertiesYet, style: .uxCalloutMedium)
   ```

#### Key Guidelines
- Localization keys are converted to camelCase constants (e.g., "No properties yet" → `Loc.noPropertiesYet`)
- The English value in the xcstrings file becomes the fallback text
- Always import `Loc` module when using localization constants
- Generated constants are found in `Modules/Loc/Sources/Loc/Generated/Strings.swift`

#### Hierarchical Naming Structure
- Use dot notation for hierarchical organization: `"QR.join.title"`
- This creates nested enums in generated code: `Loc.Qr.Join.title`
- Groups related strings together for better organization
- Examples:
  - `"QR.join.title"` → `Loc.Qr.Join.title`
  - `"SpaceShare.Join.button"` → `Loc.SpaceShare.Join.button`

#### Working with Large Localization Files
- The Localizable.xcstrings file is very large (160,000+ lines)
- Use targeted search with `grep` or `rg` to find specific entries
- When adding new entries, find the alphabetical position carefully
- Be patient with file operations - the file size makes edits slower
- Always run `make generate-middle` after adding new localization keys

#### Before Adding New Localization Keys
**IMPORTANT**: Always search for existing keys before adding new ones:

1. **Search generated constants first**:
   ```bash
   rg "yourSearchTerm" Modules/Loc/Sources/Loc/Generated/Strings.swift
   ```
   This file contains all available localization constants with their fallback values.

2. **Check for related/similar keys**: Look for keys that might already exist with similar meanings:
   - `cameraBlockTitle` instead of creating "Take photo or video"
   - `cameraBlockSubtitle` instead of creating "Capture a moment..."
   - `camera`, `photo`, `picture` for synonyms

3. **Pattern matching**: Use existing patterns:
   - Block titles: `[feature]BlockTitle`
   - Block subtitles: `[feature]BlockSubtitle`
   - Common words: `camera`, `photo`, `picture`, `video(1)`

4. **Import Loc module**: Always add `import Loc` to files using localization

#### Efficient Localization Workflow
1. Check `Modules/Loc/Sources/Loc/Generated/Strings.swift` for existing keys
2. Search for similar functionality that might already have localization
3. Only add new keys if absolutely necessary
4. Use semantic, descriptive key names that follow existing patterns
5. Run `make generate-middle` after any changes

## Code Style Guidelines

### Formatting
- Use 4 spaces for indentation (no tabs)
- Opening brackets on same line (K&R style)
- Keep lines under 120-140 characters
- One blank line between functions, two between major sections

### Naming Conventions
- Classes/Structs/Protocols: PascalCase (e.g., `ChatViewModel`, `BlockActionService`)
- Variables/Functions: camelCase (e.g., `objectDetails`, `updateRows()`)
- Protocols often suffixed with `Protocol` (e.g., `BlockActionServiceProtocol`)
- Extensions: `TypeName+Feature.swift` (e.g., `RelationDetails+Extensions.swift`)

### Swift Patterns
- Prefer `guard` for early returns over nested `if` statements
- Use `@MainActor` for UI-related classes and methods
- Place imports at top: system frameworks first, then third-party, then internal modules

### Property Organization
1. @Published/@Injected properties grouped together
2. Public properties before private
3. Constants before variables
4. Properties before methods

### Modern Swift Features
- Use async/await for asynchronous code
- Leverage SwiftUI property wrappers (@State, @StateObject, @Published)
- Use trailing closures for last closure parameters
- Type inference where obvious, explicit types for clarity  

## Feature Flags System

### Overview
Most new features must be wrapped in feature flags - boolean toggles that allow turning features on/off. This enables safe feature rollouts, A/B testing, and debug-only functionality.

### Adding New Feature Flags
1. **Add to FeatureDescription+Flags**: Edit `/Modules/AnytypeCore/AnytypeCore/Utils/FeatureFlags/FeatureDescription+Flags.swift`
   ```swift
   static let yourFeatureName = FeatureDescription(
       title: "Your Feature Name",
       type: .feature(author: "Your Name", releaseVersion: "X.X.X"),
       defaultValue: false,
       debugValue: true
   )
   ```

2. **Generate constants**: Run `make generate` to create `FeatureFlags.yourFeatureName` static property

3. **Wrap feature code**:
   ```swift
   import AnytypeCore
   
   if FeatureFlags.yourFeatureName {
       // Your feature code here
   }
   ```

### Feature Flag Types
- **`.debug`**: Debug-only features, never enabled in production
- **`.feature(author:releaseVersion:)`**: Production features with metadata

### Configuration Options
- **defaultValue**: Value for both release variants when uniform behavior is needed
- **releaseAnytypeValue/releaseAnyAppValue**: Different values for different app variants  
- **debugValue**: Value used in debug builds (usually `true` for testing)

### Usage Patterns
```swift
// Conditional UI elements
if FeatureFlags.newHome {
    NewHomeView()
} else {
    LegacyHomeView()  
}

// Feature gates in existing flows
SpaceTypePickerRow(...)
    .opacity(FeatureFlags.joinSpaceViaQRCode ? 1.0 : 0.0)
```

### Best Practices
- Always wrap new feature entry points with feature flags
- Use descriptive flag names that clearly indicate the feature
- Set `debugValue: true` for features under development
- Include author and target release version for production features

## Icon System

### Overview
The project uses a code-generated icon system that creates Swift constants from image assets. Icons are organized by size (e.g., x18, x24, x32, x40) and accessed through generated `ImageAsset` properties.

### Icon Assets Location
- **Main assets**: `/Modules/Assets/Sources/Assets/Resources/Assets.xcassets/`
- **Icon sizes**: Located in `DesignSystem/` subdirectory (x18, x19, x22, x24, x28, x32, x40, x54)

### Using Icons in Code
```swift
// Icons are accessed through generated ImageAsset properties
Image(asset: .X32.qrCode)        // For a 32pt QR code icon
Image(asset: .X24.search)        // For a 24pt search icon
Image(asset: .Channel.chat)      // For channel-specific icons
```

### Adding New Icons
1. **Export SVG from Figma**: 
   - Icons in Figma follow naming pattern like "32/qr code"
   - Export as SVG format

2. **Add to Assets.xcassets**:
   - Navigate to the appropriate size folder (e.g., `x32/` for 32pt icons)
   - Create a new Image Set (e.g., `QRCode.imageset`)
   - Add the SVG/PDF file and update `Contents.json`
   - Follow existing naming conventions (camelCase)

3. **Generate code**: 
   ```bash
   make generate
   ```
   This runs SwiftGen to generate the `ImageAsset` constants

### Naming Conventions
- **Figma**: "32/qr code" (size/icon name with spaces)
- **Asset folder**: `QRCode.imageset` (PascalCase)
- **Swift code**: `.X32.qrCode` (uppercase size + camelCase property)

### Example: Adding a New Icon
1. Export "32/new icon" from Figma as SVG
2. Add to `/Modules/Assets/.../Assets.xcassets/DesignSystem/x32/NewIcon.imageset/`
3. Run `make generate`
4. Use in code: `Image(asset: .X32.newIcon)`

## Architecture

### Key Technologies
- **Swift & SwiftUI**: Primary development language and UI framework
- **Combine**: For reactive programming and data binding
- **Factory**: Dependency injection framework
- **Middleware**: Custom binary framework for core functionality
- **Protobuf**: For communication with the middleware

### Project Structure
```
Anytype/
├── Sources/
│   ├── ApplicationLayer/     # App lifecycle, coordinators, global state
│   ├── PresentationLayer/    # UI components, ViewModels, flows
│   ├── ServiceLayer/         # Business logic, data services
│   ├── Models/               # Data models, entities
│   ├── CoreLayer/           # Core utilities, networking
│   └── Design system/       # Reusable UI components, themes
├── Modules/                  # Swift packages (internal frameworks)
│   ├── Services/            # Core services package
│   ├── AnytypeCore/         # Core utilities package
│   ├── ProtobufMessages/    # Generated protobuf code
│   └── ...
├── Dependencies/
│   └── Middleware/          # Binary framework for core functionality
└── AnyTypeTests/           # Unit and integration tests
```

### Dependency Injection
The project uses Factory for dependency injection. Services are registered in:
- `Anytype/Sources/ServiceLayer/ServicesDI.swift`
- `Modules/Services/Sources/ServicesDI.swift`

### Key Patterns
- **MVVM Architecture**: ViewModels handle business logic for SwiftUI views
- **Coordinator Pattern**: Navigation is handled by coordinator objects
- **Repository Pattern**: Data access is abstracted through service layers
- **Protocol-Oriented Programming**: Heavy use of protocols for testability

### Data Flow
1. **Middleware Layer**: Handles data persistence and synchronization
2. **Service Layer**: Provides high-level APIs for data operations
3. **ViewModels**: Transform data for presentation
4. **Views**: SwiftUI views display the data

## Common Tasks

### Adding a New Feature
1. Create models in `Models/` if needed
2. Add service layer logic in `ServiceLayer/`
3. Create ViewModel in appropriate `PresentationLayer/` subdirectory
4. Build UI components using SwiftUI
5. Add tests in `AnyTypeTests/`

### Working with Middleware
- The middleware is a pre-compiled binary framework
- Communication happens through Protobuf messages
- See `Modules/ProtobufMessages/` for message definitions

## Git Workflow
- Main branch: `develop`
- Feature branches: `ios-XXXX-description`
- Always create pull requests for code review
- Run tests before pushing changes
- **Git commit messages must be a single line** (no multi-line descriptions)
- **Do not include AI-generated signatures** in commit messages or pull requests (no "Generated with Claude Code" or "Co-Authored-By: Claude")
- **We only do work in Feature branches. We never push anything to develop or main directly**

### GitHub CLI Usage
- **Always use the `gh` tool for GitHub operations** instead of WebFetch or other tools
- Use `gh pr view <PR_NUMBER> --repo anyproto/anytype-swift` to get PR details
- Use `gh pr diff <PR_NUMBER> --repo anyproto/anytype-swift` to see code changes
- This provides faster access to PR information and avoids rate limits

### Pull Request Format
Keep pull requests simple and concise:
```
## Summary
- Brief description of changes (1-3 bullet points)
```
No test plans or testing steps needed.

### Incremental Branch Strategy
When making multiple related changes:
- Create sequential branches: `ios-XXXX-description-1`, `ios-XXXX-description-2`, etc.
- Each branch should contain one small, atomic change
- Create pull requests in a chain:
  - `ios-XXXX-description-1` → `develop`
  - `ios-XXXX-description-2` → `ios-XXXX-description-1` 
  - `ios-XXXX-description-3` → `ios-XXXX-description-2`
  - And so on...
- This allows reviewers to review changes incrementally and maintains a clear dependency chain

## Linear Issue Workflow

### Understanding Task Numbers
Before starting work on any issue, you must identify the task number:

1. **From Branch Name**: Usually the task number can be derived from the current branch name (e.g., `ios-4743-setup-linear-mpc-server` → `IOS-4743`)

2. **When on develop branch**: If you're on the `develop` branch or the task number isn't clear, ask explicitly for the task number

3. **Getting Issue Context**: Once you have the task number:
   - Use Linear MCP to fetch the issue details: `mcp__linear__get_issue` with the task ID
   - Download all issue information including description, comments, and requirements
   - **Check for attached PRs**: Linear issues often have related pull requests attached - use `gh` tool to examine these PRs for additional context about previous work or related changes
   - Use this context to understand the full scope of work

4. **Branch Management**: Switch to the appropriate feature branch using the standard naming convention (`ios-XXXX-description`)

### Linear Integration
- Use Linear MCP tools to read issue details, comments, and requirements
- Always understand the full context before starting implementation
- **Commit, push, pull request**: If doing multistaged work not done in one PR, add progress updates to corresponding Linear task and tick checkboxes
- **Update issue progress**: When completing part of a task (not the whole task):
  - Add comments with PR links using `mcp__linear__create_comment`
  - Update issue description to check off completed items using `mcp__linear__update_issue`
  - Mark checkboxes as `[X]` for completed items and add PR reference (e.g., `(PR #3517)`)
- Update issue status and add comments as needed during development

## Code Generation

The project uses several code generation tools. When renaming entities, check if they're generated and update the source files accordingly.

### Code Generation Locations
1. **SwiftGen** - Generates code from JSON/assets
   - `/Modules/Services/swiftgen.yml` - Generates BundledPropertyKey, BundledPropertiesValueProvider, etc.
   - `/Modules/Assets/Templates/swiftgen.yml` - Asset catalogs
   - `/Modules/DesignKit/Scripts/Configs/swiftgen.yml` - Design system assets
   - `/Modules/Loc/Scripts/Configs/swiftgen.yml` - Localization strings

2. **Sourcery** - Generates Swift code from templates
   - `/Modules/AnytypeCore/sourcery.yml` - Core module code generation
   - `/Modules/ProtobufMessages/sourcery.yml` - Protobuf-related code
   - `/Modules/ProtobufMessages/Scripts/Loc/sourcery.yml` - Protobuf localization

3. **Custom Generators**
   - `/Modules/ProtobufMessages/anytypeGen.yml` - Custom Anytype code generator
   - `anytype-swift-filesplit-v1` - Splits large protobuf files

### Key Commands
- `make generate-middle` - Runs all middleware-related generation (SwiftGen, Sourcery, protobuf splitting)
- `make generate` - Runs additional generators for Assets, Loc, and DesignKit

### Important Notes
- Generated files are marked with `// Generated using Sourcery/SwiftGen` - never edit these directly
- When renaming entities that appear in generated code, update the source templates/configurations
- Run `make generate-middle` after updating templates to regenerate files

## Useful Commands
- `make setup-middle` - Initial setup
- `make generate-middle` - Regenerate middleware and generated files
- `make generate` - Run all code generators

## Memories
- Do not add comments if not explicitly asked for
- For trivial PRs (renames, file moves, simple layout changes), add the GitHub label "🧠 No brainer" using `gh pr edit --add-label` (NOT in the PR title)