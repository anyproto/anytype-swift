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

### 3) How Observation Works (WWDC23)

Understanding **why** `@Observable` works helps you use it correctly.

**Property Access Tracking:**
- SwiftUI tracks which properties you **access** during `body` evaluation
- Only those accessed properties trigger view invalidation when changed
- Properties NOT read in `body` don't cause re-renders (unlike `@Published`)

```swift
@Observable
final class SettingsViewModel {
    var userName: String = ""      // Accessed in body → triggers update
    var isLoading: Bool = false    // Accessed in body → triggers update
    var analyticsData: Data = Data()  // NOT accessed in body → no update
}

struct SettingsView: View {
    @State private var model: SettingsViewModel

    var body: some View {
        // SwiftUI tracks: "this view reads userName and isLoading"
        VStack {
            Text(model.userName)           // ✓ Tracked
            if model.isLoading {           // ✓ Tracked
                ProgressView()
            }
            // model.analyticsData not read → changes won't invalidate this view
        }
    }
}
```

**Per-Instance Tracking:**
- Arrays of `@Observable` objects work efficiently
- Only the specific instance that changed triggers updates
- No need for `identifiable` tricks with observation

```swift
@Observable
final class MessageViewModel {
    var text: String
    var isRead: Bool = false
}

// Each MessageRow only updates when ITS message changes
List(model.messages) { message in
    MessageRow(message: message)  // Only this row updates when message.isRead changes
}
```

**Computed Properties Just Work:**
- Computed properties composed from stored properties are automatically tracked
- SwiftUI traces through to the underlying stored properties

```swift
@Observable
final class CartViewModel {
    var items: [Item] = []
    var discount: Double = 0

    // Computed → tracks both `items` and `discount`
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.price } - discount
    }
}
```

**Performance Benefit:**
With `@Observable`, views only update when properties they actually read change. This is more efficient than `ObservableObject` where ANY `@Published` change triggers `objectWillChange` for ALL subscribers.

### 4) Property Wrapper Decision Tree

When to use which wrapper with `@Observable`:

| Scenario | Wrapper | Why |
|----------|---------|-----|
| View **owns** model lifecycle | `@State` | View creates and manages the model |
| Model shared **app-wide** | `@Environment` | Injected at app root, read anywhere |
| Just need **bindings** ($syntax) | `@Bindable` | Pass to TextField, Toggle, etc. |
| Just **reading** the model | Nothing | Direct property access triggers tracking |

```swift
// View OWNS the model (creates it)
struct ChatView: View {
    @State private var model: ChatViewModel  // ← @State

    init(chatId: String) {
        _model = State(wrappedValue: ChatViewModel(chatId: chatId))
    }
}

// Model passed from parent, need bindings
struct MessageEditor: View {
    @Bindable var draft: DraftMessage  // ← @Bindable for $draft.text

    var body: some View {
        TextField("Message", text: $draft.text)
    }
}

// Just reading, no bindings needed
struct MessageRow: View {
    let message: MessageViewModel  // ← Nothing! Just read properties

    var body: some View {
        Text(message.text)
        Image(systemName: message.isRead ? "checkmark.circle.fill" : "circle")
    }
}
```

**Migration from ObservableObject:**

| Old | New |
|-----|-----|
| `@StateObject` | `@State` |
| `@ObservedObject` | `@Bindable` or nothing |
| `@EnvironmentObject` | `@Environment` |

### 5) Migration from ObservableObject (WWDC23)

Step-by-step conversion from legacy `ObservableObject`:

**Before (ObservableObject):**
```swift
class SettingsViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var notifications: Bool = true

    private var cancellables = Set<AnyCancellable>()
}

struct SettingsView: View {
    @StateObject private var model = SettingsViewModel()

    var body: some View {
        TextField("Name", text: $model.userName)
        Toggle("Notifications", isOn: $model.notifications)
    }
}
```

**After (@Observable):**
```swift
@Observable
final class SettingsViewModel {
    var userName: String = ""
    var notifications: Bool = true

    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
}

struct SettingsView: View {
    @State private var model = SettingsViewModel()

    var body: some View {
        @Bindable var model = model  // Local binding for $ syntax
        TextField("Name", text: $model.userName)
        Toggle("Notifications", isOn: $model.notifications)
    }
}
```

**Migration Steps:**
1. Remove `ObservableObject` conformance, add `@Observable` macro
2. Remove `@Published` from all properties (observation is automatic)
3. Add `@ObservationIgnored` to properties that shouldn't trigger updates
4. Change `@StateObject` → `@State` in views
5. For `$` binding syntax, use `@Bindable var model = model` in body
6. Replace `@EnvironmentObject` with `@Environment`

**Note:** Anytype already uses `@Observable` - this section is for understanding legacy code during migrations.

### 6) Dependency Injection (Factory)

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

### 7) Split Large Bodies

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

### 8) ViewState Enum Pattern

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

### 9) Task and onChange Usage

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

### 10) Large View File Organization

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
