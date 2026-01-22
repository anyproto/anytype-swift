---
name: swiftui-patterns-developer
description: SwiftUI view structure, composition, and best practices. Use when refactoring SwiftUI views, organizing view files, or extracting subviews.
---

# SwiftUI Patterns Developer (Smart Router)

## Purpose
Apply consistent structure and patterns to SwiftUI views, with focus on ordering, subview extraction, and proper composition.

## When Auto-Activated
- Refactoring SwiftUI view structure
- Organizing view file layout
- Splitting large views into subviews
- Keywords: view structure, view ordering, split view, extract subview, large view, refactor view

## Core Guidelines

### 1) View Ordering (top -> bottom)

Follow Anytype's property organization from IOS_DEVELOPMENT_GUIDE.md:

```swift
struct ExampleView: View {
    // 1. Property wrappers (@State, @Injected, @Environment)
    @State private var model: ExampleViewModel
    @Injected(\.settingsService) private var settingsService
    @Environment(\.dismiss) private var dismiss

    // 2. Public properties (let/var)
    let title: String

    // 3. Private properties
    private var cancellables = Set<AnyCancellable>()

    // 4. Computed properties
    private var hasItems: Bool { !model.items.isEmpty }

    // 5. init (if needed)
    init(title: String) {
        self.title = title
        _model = State(wrappedValue: ExampleViewModel(title: title))
    }

    // 6. body
    var body: some View {
        content
            .task { await model.startSubscriptions() }
    }

    // 7. Computed view builders
    private var content: some View { ... }

    // 8. Helper / async functions
    private func handleTap() { ... }
}
```

### 2) ViewModel Pattern (Anytype Standard)

Anytype uses **MVVM with ViewModels**. Always use ViewModels for business logic:

```swift
// View - lightweight, UI only
struct ChatView: View {
    @State private var model: ChatViewModel

    init(spaceId: String, chatId: String) {
        _model = State(wrappedValue: ChatViewModel(spaceId: spaceId, chatId: chatId))
    }

    var body: some View {
        content
            .task { await model.startSubscriptions() }
    }

    private var content: some View {
        List(model.messages) { message in
            MessageRow(message: message)
        }
    }
}

// ViewModel - handles business logic
@MainActor
@Observable
final class ChatViewModel {
    var messages: [Message] = []

    @ObservationIgnored
    @Injected(\.chatService) private var chatService

    func startSubscriptions() async {
        // Heavy work here, not in init
    }

    func sendMessage(_ text: String) async {
        // Business logic
    }
}
```

**Key points:**
- Use `@State private var model: ViewModel` in views
- Initialize ViewModel in view's `init` with `_model = State(wrappedValue:)`
- Keep ViewModel init cheap, heavy work in `.task`
- Use `@Observable` macro (not `ObservableObject`)
- Mark ViewModels with `@MainActor`

### 3) Dependency Injection (Factory)

Anytype uses **Factory DI**, not SwiftUI Environment for services:

```swift
// ✅ CORRECT - Factory DI
@Injected(\.chatService) private var chatService

// ❌ WRONG - Environment for services
@Environment(ChatService.self) private var chatService
```

**Environment is for:**
- System values: `@Environment(\.dismiss)`, `@Environment(\.colorScheme)`
- SwiftUI-provided context

**@Injected is for:**
- App services: `@Injected(\.chatService)`
- Repositories: `@Injected(\.userRepository)`
- Any business logic dependencies

### 4) Split Large Bodies

If `body` grows beyond a screen, split into smaller subviews:

```swift
// Computed view properties (same file)
var body: some View {
    List {
        header
        filters
        results
    }
}

private var header: some View { ... }
private var filters: some View { ... }
private var results: some View { ... }
```

```swift
// Extracted subview (reusable or complex)
struct HeaderSection: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            AnytypeText(title, style: .heading)
            if let subtitle {
                AnytypeText(subtitle, style: .bodyRegular)
            }
        }
    }
}
```

### 5) ViewState Enum Pattern

For views with loading/error/loaded states:

```swift
enum ViewState {
    case loading
    case error(String)
    case loaded
}

@MainActor
@Observable
final class FeedViewModel {
    var viewState: ViewState = .loading
    var posts: [Post] = []

    func loadPosts() async {
        do {
            posts = try await feedService.getFeed()
            viewState = .loaded
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
}

struct FeedView: View {
    @State private var model: FeedViewModel

    var body: some View {
        content
            .task { await model.loadPosts() }
    }

    @ViewBuilder
    private var content: some View {
        switch model.viewState {
        case .loading:
            ProgressView()
        case .error(let message):
            ErrorView(message: message, retry: { Task { await model.loadPosts() } })
        case .loaded:
            List(model.posts) { post in
                PostRow(post: post)
            }
        }
    }
}
```

### 6) Task and onChange Usage

```swift
// Initial load
.task {
    await model.startSubscriptions()
}

// React to state changes
.task(id: searchText) {
    guard !searchText.isEmpty else { return }
    await model.search(query: searchText)
}

.onChange(of: selectedTab) { oldValue, newValue in
    // Handle tab change
}
```

### 7) Large View File Organization

When file exceeds ~300 lines:

```swift
struct LargeView: View {
    // Properties and body here
}

// MARK: - Subviews
private extension LargeView {
    var header: some View { ... }
    var content: some View { ... }
}

// MARK: - Actions
private extension LargeView {
    func loadData() async { ... }
    func handleTap() { ... }
}
```

## Common Mistakes

### Using @Environment for Services
```swift
// ❌ WRONG - Environment for app services
@Environment(FeedService.self) private var feedService

// ✅ CORRECT - Factory DI
@Injected(\.feedService) private var feedService
```

### Missing ViewModel for Complex Views
```swift
// ❌ WRONG - Business logic in view
struct FeedView: View {
    @State private var posts: [Post] = []

    private func loadPosts() async {
        // Business logic directly in view
    }
}

// ✅ CORRECT - ViewModel handles business logic
struct FeedView: View {
    @State private var model: FeedViewModel
    // ViewModel handles loadPosts()
}
```

### Avoid Group with Conditionals + Lifecycle Modifiers

```swift
// ❌ WRONG - onAppear can fire multiple times
var body: some View {
    Group {
        if model.isLoading {
            ProgressView()
        } else {
            content
        }
    }
    .onAppear { model.onAppear() }
}

// ✅ CORRECT - Use @ViewBuilder
var body: some View {
    loadingContent
        .onAppear { model.onAppear() }
}

@ViewBuilder
private var loadingContent: some View {
    if model.isLoading {
        ProgressView()
    } else {
        content
    }
}
```

## Related Skills

- **ios-dev-guidelines** -> Full MVVM/Coordinator patterns, code style
- **swiftui-performance-developer** -> Performance optimization
- **design-system-developer** -> Icons, typography, colors

---

**Navigation**: This skill provides SwiftUI structure patterns. For full architecture guidance, see `IOS_DEVELOPMENT_GUIDE.md`.

**Attribution**: View structure patterns adapted from [Dimillian/Skills](https://github.com/Dimillian/Skills), aligned with Anytype MVVM architecture.
