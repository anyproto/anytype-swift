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
- **For compilation check**: Use "Build for Testing" (`Cmd+Shift+U`) instead of normal build
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
- **Do not include AI-generated signatures** in commit messages (no "Generated with Claude Code" or "Co-Authored-By: Claude")
- **We only do work in Feature branches. We never push anything to develop or main directly**

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

## Useful Commands
- `make setup-middle` - Initial setup
- `make generate-middle` - Regenerate middleware and generated files

## Memories
- Do not add comments if not explicitly asked for