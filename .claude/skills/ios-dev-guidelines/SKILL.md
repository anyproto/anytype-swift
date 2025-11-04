# iOS Development Guidelines (Smart Router)

## Purpose
Context-aware routing to iOS development patterns, code style, and architecture guidelines. This skill provides critical rules and points you to comprehensive documentation.

## When Auto-Activated
- Working with `.swift` files
- Discussing ViewModels, Coordinators, architecture
- Refactoring or formatting code
- Keywords: swift, swiftui, mvvm, async, await, refactor

## 🚨 CRITICAL RULES (NEVER VIOLATE)

1. **NEVER trim whitespace-only lines** - Preserve blank lines with spaces/tabs exactly as they appear
2. **NEVER edit generated files** - Files marked with `// Generated using Sourcery/SwiftGen`
3. **NEVER use hardcoded strings in UI** - Always use localization constants (`Loc.*`)
4. **NEVER add comments** unless explicitly requested
5. **ALWAYS update tests and mocks when refactoring** - Search for all references and update
6. **Use feature flags for new features** - Wrap experimental code for safe rollouts

## 📋 Quick Checklist

Before completing any task:
- [ ] Whitespace-only lines preserved (not trimmed)
- [ ] No hardcoded strings (use `Loc` constants)
- [ ] Tests and mocks updated if dependencies changed
- [ ] Generated files not edited
- [ ] Feature flags applied to new features
- [ ] No comments added (unless requested)

## 🎯 Common Patterns

### MVVM ViewModel
```swift
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Injected(\.chatService) private var chatService

    func sendMessage(_ text: String) async {
        // Business logic here
    }
}
```

### Coordinator
```swift
@MainActor
final class ChatCoordinator: ObservableObject {
    @Published var route: Route?

    enum Route {
        case settings
        case memberList
    }
}
```

### Dependency Injection
```swift
extension Container {
    var chatService: Factory<ChatServiceProtocol> {
        Factory(self) { ChatService() }
    }
}

// Usage in ViewModel
@Injected(\.chatService) private var chatService
```

## 🗂️ Project Structure

```
Anytype/Sources/
├── ApplicationLayer/    # App lifecycle, coordinators
├── PresentationLayer/   # UI components, ViewModels
├── ServiceLayer/        # Business logic, data services
├── Models/             # Data models, entities
└── CoreLayer/          # Core utilities, networking
```

## 🔧 Code Style Quick Reference

- **Indentation**: 4 spaces (no tabs)
- **Naming**: PascalCase (types), camelCase (variables/functions)
- **Extensions**: `TypeName+Feature.swift`
- **Property order**: @Published/@Injected → public → private → computed → init → methods
- **Avoid nested types** - Extract to top-level with descriptive names
- **Enum exhaustiveness** - Use explicit switch statements (enables compiler warnings)

## 📚 Complete Documentation

**Full Guide**: `Anytype/Sources/IOS_DEVELOPMENT_GUIDE.md`

For comprehensive coverage of:
- Detailed formatting rules
- Swift best practices (guard, @MainActor, async/await)
- Architecture patterns (MVVM, Coordinator, Repository)
- Property organization
- Common mistakes from past incidents
- Testing & mock management
- Complete code examples

## 🚨 Common Mistakes (Historical)

### Autonomous Committing (2025-01-28)
**NEVER commit without explicit user request** - Committing is destructive

### Wildcard File Deletion (2025-01-24)
Used `rm -f .../PublishingPreview*.swift` - deleted main UI component
- Always check with `ls` first
- Delete files individually

### Incomplete Mock Updates (2025-01-16)
Refactored dependencies but forgot `MockView.swift`
- Search: `rg "oldName" --type swift`
- Update: tests, mocks, DI registrations

## 🔗 Related Skills & Docs

- **localization-developer** → `LOCALIZATION_GUIDE.md` - Localization system
- **code-generation-developer** → `CODE_GENERATION_GUIDE.md` - Feature flags, make generate
- **design-system-developer** → `DESIGN_SYSTEM_MAPPING.md` - Icons, typography

---

**Navigation**: This is a smart router. For deep technical details, always refer to `IOS_DEVELOPMENT_GUIDE.md`.
