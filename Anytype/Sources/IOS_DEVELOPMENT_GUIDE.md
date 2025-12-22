# iOS Development Guide

Complete guide to iOS development patterns, architecture, and best practices for the Anytype iOS app.

*Last updated: 2025-12-18*

## Overview

The Anytype iOS app is built with Swift and SwiftUI, following MVVM architecture with Coordinator pattern for navigation. This guide covers the patterns, code style, and best practices used throughout the project.

## ⚠️ CRITICAL RULES

1. **NEVER trim whitespace-only lines** - Preserve blank lines with spaces/tabs exactly as they appear
2. **NEVER edit generated files** - Files marked with `// Generated using Sourcery/SwiftGen`
3. **NEVER use hardcoded strings** - Always use localization constants (`Loc.*`)
4. **ALWAYS update tests and mocks** - When refactoring, update all references
5. **Use feature flags for new features** - Wrap experimental code for safe rollouts
6. **Follow MVVM pattern** - ViewModels handle business logic, Views are lightweight

## 🏗️ Architecture

### Technologies

- **Swift & SwiftUI** - Primary language and UI framework
- **Combine** - Reactive programming
- **Factory** - Dependency injection
- **Middleware** - Custom binary framework for core functionality
- **Protobuf** - Middleware communication

### Project Structure

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
├── Loc/                # Localization
└── Assets/             # Design assets
```

### Key Architectural Patterns

#### 1. MVVM (Model-View-ViewModel)

**View** (SwiftUI):
```swift
struct ChatView: View {
    @State private var model: ChatViewModel

    init() {
        _model = State(wrappedValue: ChatViewModel())
    }

    var body: some View {
        // UI only, no business logic
    }
}
```

**ViewModel** (using `@Observable` macro - preferred):
```swift
@MainActor
@Observable
final class ChatViewModel {
    var messages: [Message] = []

    @ObservationIgnored
    @Injected(\.chatService) private var chatService

    func sendMessage(_ text: String) async {
        // Business logic here
    }
}
```

> **Note**: Use `@Observable` macro instead of `ObservableObject`. Properties are observed by default - no `@Published` needed. Use `@ObservationIgnored` for properties that shouldn't trigger view updates (DI, navigation, private state).

#### 2. Coordinator Pattern

Coordinators handle navigation:

```swift
@MainActor
@Observable
final class ChatCoordinator {
    var route: Route?

    enum Route {
        case settings
        case memberList
    }

    func showSettings() {
        route = .settings
    }
}
```

#### 3. Repository Pattern

Data access abstracted through services:

```swift
protocol ChatRepository {
    func fetchMessages() async throws -> [Message]
    func sendMessage(_ message: Message) async throws
}

final class ChatRepositoryImpl: ChatRepository {
    // Implementation
}
```

#### 4. Dependency Injection (Factory)

```swift
extension Container {
    var chatService: Factory<ChatServiceProtocol> {
        Factory(self) { ChatService() }
    }
}

// Usage in ViewModel
@Injected(\.chatService) private var chatService
```

## 🔧 Code Style

### Formatting

- **Indentation**: 4 spaces (no tabs)
- **Bracket style**: K&R (opening bracket on same line)
- **Line length**: 120-140 characters
- **Blank lines**: One between functions, two between sections
- **Whitespace-only lines**: NEVER trim - preserve exactly as is

```swift
// ✅ CORRECT
class ChatViewModel {
    @Published var messages: [Message] = []
                                              // ← Preserve blank line with spaces
    func sendMessage() {
        // Implementation
    }
}

// ❌ WRONG
class ChatViewModel {
    @Published var messages: [Message] = []
// ← Trimmed whitespace - breaks formatting consistency
    func sendMessage() {
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes, Structs, Protocols | PascalCase | `ChatViewModel`, `UserService` |
| Variables, Functions | camelCase | `objectDetails`, `updateRows()` |
| Extensions | `TypeName+Feature.swift` | `ChatView+Actions.swift` |
| Protocols | Often suffixed with `Protocol` | `ChatServiceProtocol` |

### Import Order

```swift
// System frameworks
import Foundation
import SwiftUI
import Combine

// Third-party
import Factory

// Internal
import AnytypeCore
import Services
```

### Property Organization

```swift
class ViewModel: ObservableObject {
    // 1. Property wrappers
    @Published var data: [Item] = []
    @Injected(\.service) private var service

    // 2. Public properties
    let title: String

    // 3. Private properties
    private var cancellables = Set<AnyCancellable>()

    // 4. Constants
    private let maxItems = 100

    // 5. Computed properties
    var isEmpty: Bool { data.isEmpty }

    // 6. Init
    init(title: String) {
        self.title = title
    }

    // 7. Public methods
    func loadData() async { }

    // 8. Private methods
    private func processData() { }
}
```

## 🎯 Swift Best Practices

### Use Guard for Early Returns

```swift
// ✅ CORRECT
func processUser(_ user: User?) {
    guard let user else { return }
    // Continue with user
}

// ❌ WRONG
func processUser(_ user: User?) {
    if let user = user {
        // Deep nesting
    }
}
```

### Use @MainActor for UI Classes

```swift
// ✅ CORRECT - Ensures UI updates on main thread
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
}

// ❌ WRONG - Can cause UI threading issues
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
}
```

### Async/Await over Completion Handlers

```swift
// ✅ CORRECT - Modern async/await
func fetchData() async throws -> [Item] {
    try await service.fetch()
}

// ❌ WRONG - Old completion handler style
func fetchData(completion: @escaping (Result<[Item], Error>) -> Void) {
    service.fetch(completion: completion)
}
```

### Avoid Nested Types

```swift
// ❌ WRONG - Nested type
struct ChatView: View {
    enum MessageType {  // Nested in View
        case text, image
    }
}

// ✅ CORRECT - Top-level with descriptive name
enum ChatMessageType {
    case text, image
}

struct ChatView: View {
    // Use ChatMessageType
}
```

### Enum Exhaustiveness

Always use explicit switch statements to enable compiler warnings when new cases are added:

```swift
// ✅ CORRECT - Compiler warns if new case added
var showManageButton: Bool {
    switch self {
    case .sharedSpaces:
        return true
    case .editors:
        return false
    }
}

// ❌ WRONG - Default fallback prevents warnings
var showManageButton: Bool {
    if case .sharedSpaces = self { return true }
    return false  // Won't warn about new cases
}
```

**Exception**: Only use default fallback for super obvious single-case checks:
```swift
var isSharedSpaces: Bool {
    if case .sharedSpaces = self { return true }
    return false
}
```

### SwiftUI Property Wrappers

Use appropriate property wrappers:

```swift
// State management
@State private var isLoading = false           // Local view state
@StateObject private var model = ViewModel()    // Own the ViewModel
@ObservedObject var model: ViewModel            // Passed from parent

// Published (in ObservableObject)
@Published var data: [Item] = []

// Dependency injection
@Injected(\.service) private var service

// Environment
@Environment(\.dismiss) private var dismiss
```

### Trailing Closures

```swift
// ✅ CORRECT
Button("Submit") {
    submit()
}

// ❌ WRONG - Unnecessary parentheses
Button("Submit", action: {
    submit()
})
```

### Type Inference

```swift
// ✅ CORRECT - Infer when obvious
let items = [1, 2, 3]
let name = "Chat"

// ✅ CORRECT - Explicit when needed
let items: [Item] = fetchItems()
let callback: (String) -> Void = handle
```

### SwiftUI Best Practices

#### Use `foregroundStyle()` instead of `foregroundColor()`

`foregroundColor()` is deprecated. Use `foregroundStyle()` with explicit `Color` type:

```swift
// ❌ WRONG - Deprecated
Text("Hello")
    .foregroundColor(.red)

// ❌ WRONG - Type inference doesn't work
Text("Hello")
    .foregroundStyle(.red)

// ✅ CORRECT - Explicit Color type
AnytypeText("Hello", style: .bodyRegular)
    .foregroundStyle(Color.Text.primary)
```

#### Use `AnytypeText` instead of plain `Text`

Never use SwiftUI's plain `Text` view. Always use `AnytypeText` which encapsulates design system typography:

```swift
// ❌ WRONG - Plain Text
Text("Hello World")

// ✅ CORRECT - AnytypeText with design system style
AnytypeText("Hello World", style: .bodyRegular)

// ✅ With localization
AnytypeText(Loc.welcomeMessage, style: .heading)
```

`AnytypeText` ensures consistent typography and automatically applies design system fonts.

## 🧪 Testing & Mocks

### Always Update Tests When Refactoring

When renaming properties or dependencies:

**1. Search for all references**:
```bash
rg "oldName" --type swift
```

**2. Update all locations**:
- Unit tests: `AnyTypeTests/`
- Preview mocks: `Anytype/Sources/PreviewMocks/`
- Mock implementations: `Anytype/Sources/PreviewMocks/Mocks/`
- DI registrations: `MockView.swift`, test setup files

**Common mistake** (2025-01-16): Refactored `spaceViewStorage` → `spaceViewsStorage` in production code but forgot to update `MockView.swift`, causing test failures.

### Mock Generation

Use Sourcery for automatic mock generation:

```swift
// sourcery: AutoMockable
protocol ChatService {
    func fetchMessages() async throws -> [Message]
}

// After make generate:
// ChatServiceMock automatically created
```

## 🗑️ Code Cleanup

### Remove Unused Code

After refactoring, always delete:
- Unused properties
- Unused functions
- Entire files that are no longer referenced

**Example**: If removing a feature, delete:
1. ViewModel file
2. View file
3. Service implementation
4. Tests
5. Mocks
6. Localization keys (see LOCALIZATION_GUIDE.md)

### Search Before Deleting

```bash
# Check if type is still used
rg "MyOldViewModel" --type swift

# Check if file is imported
rg "import MyOldModule" --type swift
```

## 🚨 Common Mistakes to Avoid

### ❌ Autonomous Committing (2025-01-28)

**NEVER commit without explicit user request**. Committing is destructive and should only happen when user approves.

### ❌ Wildcard File Deletion (2025-01-24)

```bash
# WRONG - Used wildcard
rm -f .../PublishingPreview*.swift  # Accidentally deleted main UI component

# CORRECT - Check first, delete individually
ls .../PublishingPreview*.swift  # Verify what will be deleted
rm .../PublishingPreviewViewModel.swift  # Delete specific file
```

### ❌ Incomplete Mock Updates (2025-01-16)

Refactored production code but forgot to update `MockView.swift`. Always search for ALL references:

```bash
rg "spaceViewStorage" --type swift  # Find all uses
# Update all: production, tests, mocks, DI
```

### ❌ Trimming Whitespace-Only Lines

This breaks formatting consistency. NEVER trim blank lines that contain spaces/tabs.

### ❌ Hardcoded Strings

```swift
// WRONG
Text("Add Member")

// CORRECT
Text(Loc.addMember)
```

### ❌ Editing Generated Files

```swift
// File: Generated/FeatureFlags.swift
// ❌ Don't edit this file - changes will be overwritten
```

### ❌ SwiftUI Group with Lifecycle Modifiers (2025-12-18)

`Group` distributes modifiers to its children. When used with conditionals and lifecycle modifiers (`onAppear`, `task`), callbacks can fire multiple times as views switch between branches.

```swift
// ❌ WRONG - onAppear/task can fire multiple times when loadingDocument changes
var body: some View {
    Group {
        if model.loadingDocument {
            Spacer()
        } else {
            content
        }
    }
    .onAppear { model.onAppear() }
    .task { await model.startSubscriptions() }
}

// ✅ CORRECT - Extract to @ViewBuilder, modifiers applied once
var body: some View {
    loadingContent
        .onAppear { model.onAppear() }
        .task { await model.startSubscriptions() }
}

@ViewBuilder
private var loadingContent: some View {
    if model.loadingDocument {
        Spacer()
    } else {
        content
    }
}
```

**Also avoid Group inside ForEach with modifiers**:
```swift
// ❌ WRONG - Group distributes onDrop to each case
ForEach(items) { item in
    Group {
        switch item.type { ... }
    }
    .onDrop(...)
}

// ✅ CORRECT - Extract switch to @ViewBuilder function
ForEach(items) { item in
    itemContent(item)
        .onDrop(...)
}

@ViewBuilder
private func itemContent(_ item: Item) -> some View {
    switch item.type { ... }
}
```

**Reference**: [SwiftUI Group Still Considered Harmful](https://twocentstudios.com/2025/12/12/swiftui-group-still-considered-harmful/)

### ❌ Computed Properties Accessing Storage in ViewModels

Using computed properties that access storage/services causes unnecessary calls on every view re-render:

```swift
// ❌ WRONG - Called on every view re-render
@MainActor
final class ProfileViewModel: ObservableObject {
    @Injected(\.membershipStorage) private var storage

    var userName: String {
        storage.currentStatus.name  // Called every re-render!
    }
}

// ✅ CORRECT - Captured once at initialization
@MainActor
final class ProfileViewModel: ObservableObject {
    let userName: String

    init() {
        userName = Container.shared.membershipStorage().currentStatus.name
    }
}

// ✅ CORRECT - For values that change, subscribe to updates
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var userName: String = ""
    private var cancellables = Set<AnyCancellable>()

    init() {
        Container.shared.membershipStorage()
            .statusPublisher
            .map(\.name)
            .assign(to: &$userName)
    }
}
```

**Rule**: If the value doesn't change during the view's lifetime, use `let` constant. If it can change, subscribe to updates with `@Published`.

## 📚 Integration with Other Guides

- **Localization**: See `LOCALIZATION_GUIDE.md` for using `Loc.*` constants
- **Code Generation**: See `CODE_GENERATION_GUIDE.md` for feature flags and `make generate`
- **Design System**: See `DESIGN_SYSTEM_MAPPING.md` for icons, typography, colors

## 💡 Best Practices Summary

### Code Organization

✅ **DO**:
- Use MVVM pattern (View → ViewModel → Service → Repository)
- Inject dependencies with `@Injected`
- Mark UI classes with `@MainActor`
- Use async/await for asynchronous code
- Use `guard` for early returns
- Organize properties: wrappers → public → private → computed → init → methods

❌ **DON'T**:
- Put business logic in Views
- Use nested types (extract to top-level)
- Use completion handlers (use async/await)
- Trim whitespace-only lines
- Hardcode strings (use Loc.*)
- Use computed properties accessing storage in ViewModels (causes re-render overhead)
- Use `Group` with conditionals + lifecycle modifiers (use `@ViewBuilder` instead)

### Testing

✅ **DO**:
- Update tests when refactoring
- Use Sourcery for mock generation
- Search for all references before renaming

❌ **DON'T**:
- Forget to update mocks
- Skip test updates during refactoring

### File Management

✅ **DO**:
- Use descriptive file names
- Follow extension naming: `Type+Feature.swift`
- Delete unused files
- Search before deleting

❌ **DON'T**:
- Use wildcard deletion
- Leave orphaned files
- Keep unused code "just in case"

## 📖 Quick Reference

**Create ViewModel**:
```swift
@MainActor
final class FeatureViewModel: ObservableObject {
    @Published var data: [Item] = []
    @Injected(\.service) private var service

    func loadData() async throws {
        data = try await service.fetch()
    }
}
```

**Create Coordinator**:
```swift
@MainActor
final class FeatureCoordinator: ObservableObject {
    @Published var route: Route?

    enum Route { case detail, settings }
}
```

**Dependency Injection**:
```swift
// Register in Container
extension Container {
    var myService: Factory<MyServiceProtocol> {
        Factory(self) { MyService() }
    }
}

// Use in ViewModel
@Injected(\.myService) private var service
```

---

*This guide is the single source of truth for iOS development patterns. For quick reference, see CLAUDE.md.*