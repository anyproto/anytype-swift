# Anytype iOS Navigation System Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Core Components](#core-components)
3. [Path Item Types](#path-item-types)
4. [Navigation Flows](#navigation-flows)
5. [Key Files Reference](#key-files-reference)

---

## Architecture Overview

The Anytype iOS app uses a **custom navigation system** that wraps UIKit's `UINavigationController` with a SwiftUI interface. This provides:
- Type-safe navigation using `Hashable` path items
- Automatic view construction based on path item types
- Full control over navigation stack manipulation

### High-Level Flow
```
User Action → SpaceHubCoordinatorViewModel → HomePath mutation → AnytypeNavigationView → UINavigationController
```

### Key Concept: Type-Based View Building
Instead of using SwiftUI's native `NavigationStack`, the app uses a custom system where:
1. Navigation state is an array of `AnyHashable` items (`HomePath.path`)
2. Each item type is registered with a view builder
3. When the path changes, views are built dynamically based on item types

---

## Core Components

### 1. HomePath
**File**: `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/HomePath.swift`

A custom struct that wraps `[AnyHashable]` to represent the navigation stack.

```swift
struct HomePath: Equatable, @unchecked Sendable {
    fileprivate(set) var path: [AnyHashable]

    init(initialPath: [AnyHashable] = [])

    var count: Int
    var lastPathElement: AnyHashable?

    // Stack operations
    mutating func push(_ item: AnyHashable)       // Append to stack
    mutating func pop()                            // Remove last (minimum 1 item)
    mutating func popToRoot()                      // Keep only first item
    mutating func popToFirstOpened()               // Keep first 2 items
    mutating func popTo(_ item: AnyHashable)       // Pop to specific item
    mutating func replaceLast(_ item: AnyHashable) // Replace top item

    // Item manipulation
    mutating func insert(_ item: AnyHashable, at index: Int)
    mutating func remove(_ item: AnyHashable)      // Remove all matching
    func contains(_ item: AnyHashable) -> Bool
    func index(_ item: AnyHashable) -> Int?

    // Special operation
    mutating func openOnce(_ item: AnyHashable)    // If exists: popTo, else: push
}
```

**Important behaviors**:
- `pop()` keeps at least 1 item (the root)
- `openOnce()` is used for "singleton" screens like widgets/chat that should only appear once in the stack
- The path always starts with `SpaceHubNavigationItem()` as the root

---

### 2. AnytypeDestinationBuilderHolder
**File**: `Anytype/Sources/PresentationLayer/Common/SwiftUI/NavigationView/AnytypeDestinationBuilderHolder.swift`

A registry that maps path item types to SwiftUI view builders using reflection.

```swift
final class AnytypeDestinationBuilderHolder {
    private var builders: [String: (Any) -> AnyView?] = [:]

    // Generate unique key from type using reflection
    static func identifier(for type: Any.Type) -> String {
        String(reflecting: type)  // e.g., "Anytype.EditorScreenData"
    }

    // Register a view builder for a specific Hashable type
    func appendBuilder<D: Hashable, C: View>(
        for pathElementType: D.Type,
        @ViewBuilder destination builder: @escaping (D) -> C
    )

    // Build a view from a path item (looks up by type)
    @MainActor
    func build(_ typedData: Any) -> AnyView
}
```

**How it works**:
1. During setup, builders are registered: `builder.appendBuilder(for: EditorScreenData.self) { data in EditorView(data: data) }`
2. When building, the holder uses `String(reflecting: type(of: data))` to find the matching builder
3. If no builder is found, returns `EmptyView` with assertion failure

---

### 3. AnytypeNavigationView
**File**: `Anytype/Sources/PresentationLayer/Common/SwiftUI/NavigationView/AnytypeNavigationView.swift`

SwiftUI view that bridges to `UINavigationController` via `UIViewControllerRepresentable`.

```swift
struct AnytypeNavigationView: View {
    @Binding var path: [AnyHashable]
    @Binding var pathChanging: Bool
    let moduleSetup: (_ builder: AnytypeDestinationBuilderHolder) -> Void
}
```

**Update cycle** (`updateUIViewController`):
1. Receives new `path` array
2. For each path item:
   - Reuses existing `UIHostingController` if item already has one
   - Otherwise calls `builder.build(pathItem.base)` to create new view
3. Calls `UINavigationController.setViewControllers(...)` with animation

**View controller reuse**: The coordinator maintains `currentViewControllers` and matches by `rootView.data == pathItem` to avoid recreating views unnecessarily.

---

### 4. SpaceHubCoordinatorViewModel
**File**: `Anytype/Sources/PresentationLayer/Flows/SpaceHub/SpaceHubCoordinatorViewModel.swift`

The main navigation state manager. Holds:
- `navigationPath: HomePath` - the current navigation stack
- `currentSpaceId: String?` - the active space
- `pageNavigation: PageNavigation` - helper for programmatic navigation

**Key methods**:

```swift
// Called when user taps a space in the grid
func onSelectSpace(spaceId: String) {
    Task { try await openSpaceWithIntialScreen(spaceId: spaceId) }
}

// Opens a space with its initial screen (widget or chat)
private func openSpaceWithIntialScreen(spaceId: String) async throws

// Shows any screen, handling space changes and path updates
private func showScreen(data: ScreenData) async throws

// Called on every path change - persists last screen
func onPathChange()

// Builds initial path for a space
private func initialHomePath(spaceView: SpaceView) -> [AnyHashable]
```

---

### 5. SpaceHubPathUXTypeHelper
**File**: `Anytype/Sources/PresentationLayer/Flows/SpaceHub/Support/SpaceHubPathManager.swift`

Automatically adjusts navigation path based on space UX type. Subscribed via `startSpaceSubscription()`.

```swift
protocol SpaceHubPathUXTypeHelperProtocol: AnyObject, Sendable {
    func updateNaivgationPathForUxType(spaceView: SpaceView, path: HomePath) async -> HomePath
}
```

**Behavior by space type**:
- **Chat/OneToOne/Stream spaces**: Ensures `SpaceChatCoordinatorData` at index 1
- **Data spaces**: Ensures `HomeWidgetData` at index 1
- **None/Unrecognized**: No modification

**How it's used**:
```swift
func startSpaceSubscription() async {
    guard let spaceId = currentSpaceId else { return }
    for await spaceView in workspaceStorage.spaceViewPublisher(spaceId: spaceId).values {
        navigationPath = await spaceHubPathUXTypeHelper.updateNaivgationPathForUxType(
            spaceView: spaceView,
            path: navigationPath
        )
    }
}
```

**Important**: This helper runs continuously and modifies the path whenever the space's UX type changes. It forces widgets/chat at index 1.

---

## Path Item Types

These are `Hashable` structs/enums that represent screens in the navigation stack:

| Type | View | Location | Description |
|------|------|----------|-------------|
| `SpaceHubNavigationItem` | `SpaceHubView` | Always index 0 | Root - space selection grid |
| `HomeWidgetData` | `HomeWidgetsCoordinatorView` | Index 1 for data spaces | Widget dashboard |
| `SpaceChatCoordinatorData` | `SpaceChatCoordinatorView` | Index 1 for chat spaces | Space-level chat |
| `EditorScreenData` | `EditorCoordinatorView` | Pushed on top | Object editor (page, note, set, etc.) |
| `ChatCoordinatorData` | `ChatCoordinatorView` | Pushed on top | Object-level chat |
| `SpaceInfoScreenData` | Various | Pushed on top | Settings, type library, properties library |

### ScreenData Enum
**File**: `Anytype/Sources/PresentationLayer/TextEditor/Assembly/ScreenData.swift`

High-level enum for navigation requests. Used by `showScreen()` method.

```swift
enum ScreenData: Hashable, Identifiable, Sendable {
    case editor(EditorScreenData)
    case alert(AlertScreenData)
    case preview(MediaFileScreenData)
    case bookmark(BookmarkScreenData)
    case spaceInfo(SpaceInfoScreenData)
    case chat(ChatCoordinatorData)
    case spaceChat(SpaceChatCoordinatorData)
    case widget(HomeWidgetData)

    var objectId: String?  // For validation
    var spaceId: String    // For space switching
}
```

### LastOpenedScreen Enum
**File**: `Anytype/Sources/Utilities/UserDefaults/UserDefaultsStorage.swift`

Persisted to UserDefaults for app restart restoration.

```swift
enum LastOpenedScreen: Codable {
    case editor(EditorScreenData)
    case widgets(spaceId: String)
    case chat(ChatCoordinatorData)
    case spaceChat(SpaceChatCoordinatorData)

    var spaceId: String
}
```

---

## Navigation Flows

### A. App Startup

```
1. SpaceHubCoordinatorView appears
2. .taskWithMemoryScope { await model.setup() }
3. setup() → setupInitialScreen()
4. Check userDefaults.lastOpenedScreen:
   - .editor(data) → showScreen(.editor(data))
   - .widgets(spaceId) → showScreen(.widget(HomeWidgetData(spaceId)))
   - .chat(data) → showScreen(.chat(data))
   - .spaceChat(data) → showScreen(.spaceChat(data))
   - nil → Stay on SpaceHub (path = [SpaceHubNavigationItem])
```

### B. Opening a Space (User taps space in grid)

```
1. SpaceHubView.onSelectSpace(spaceId:) → output delegate
2. SpaceHubCoordinatorViewModel.onSelectSpace(spaceId:)
3. openSpaceWithIntialScreen(spaceId:):
   a. setActiveSpace(spaceId:) → validates space, returns SpaceView
   b. Check spaceView.initialScreenIsChat:
      - true → showScreen(.spaceChat(SpaceChatCoordinatorData))
      - false → showScreen(.widget(HomeWidgetData))
```

### C. showScreen(data: ScreenData)

```
1. Validate object exists (if data.objectId != nil):
   - Open document in preview mode
   - Check details.isSupportedForOpening
   - Show toast if unsupported

2. Check if space change needed:
   - If currentSpaceId != data.spaceId:
     - setActiveSpace(data.spaceId)
     - Build new path: initialHomePath(spaceView)
   - Else: use current navigationPath

3. Dismiss any presented sheets

4. Handle by ScreenData case:
   - .editor → currentPath.push(editorScreenData)
   - .widget → currentPath.openOnce(HomeWidgetData)
   - .spaceChat → currentPath.openOnce(SpaceChatCoordinatorData)
   - .chat → currentPath.openOnce(ChatCoordinatorData)
   - .spaceInfo → currentPath.push(data) or show sheet
   - .alert → show sheet (profileData, chatCreateData)
   - .preview → present UIKit preview controller
   - .bookmark → show Safari bookmark sheet

5. Update navigationPath if changed
```

### D. Path → View Resolution (AnytypeNavigationView)

```
1. navigationPath binding changes
2. SwiftUI calls updateUIViewController
3. For each item in path:
   - Check if existing UIHostingController matches (by data equality)
   - If found: reuse controller
   - If not: builder.build(pathItem.base) → new UIHostingController
4. Compare with current view controllers
5. If different: UINavigationController.setViewControllers(animated:)
   - Animated if last item changed
   - Not animated if middle items changed
```

### E. Path Change Persistence (onPathChange)

```
1. Called via .onChange(of: model.navigationPath)
2. Check lastPathElement type:
   - EditorScreenData → lastOpenedScreen = .editor(data)
   - HomeWidgetData → lastOpenedScreen = .widgets(spaceId)
   - ChatCoordinatorData → lastOpenedScreen = .chat(data)
   - SpaceChatCoordinatorData → lastOpenedScreen = .spaceChat(data)
   - Other → lastOpenedScreen = nil

3. If path.count == 1 (only SpaceHub):
   - currentSpaceId = nil
   - activeSpaceManager.setActiveSpace(nil)
```

### F. Space Subscription (Auto Path Correction)

```
1. .task(id: model.currentSpaceId) { await model.startSpaceSubscription() }
2. Subscribe to spaceViewPublisher(spaceId:)
3. On each SpaceView update:
   - spaceHubPathUXTypeHelper.updateNaivgationPathForUxType(spaceView, path)
   - Updates navigationPath with corrected path
4. Based on spaceView.uxType:
   - .data → ensures HomeWidgetData at index 1
   - .chat/.oneToOne/.stream → ensures SpaceChatCoordinatorData at index 1
```

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `SpaceHubCoordinatorView.swift` | Main coordinator view, registers all builders |
| `SpaceHubCoordinatorViewModel.swift` | Navigation state, showScreen(), onPathChange() |
| `HomePath.swift` | Custom navigation stack struct with manipulation methods |
| `AnytypeNavigationView.swift` | SwiftUI → UIKit bridge via UIViewControllerRepresentable |
| `AnytypeDestinationBuilderHolder.swift` | Type → View builder registry using reflection |
| `ScreenData.swift` | High-level screen enum for navigation requests |
| `UserDefaultsStorage.swift` | LastOpenedScreen persistence |
| `SpaceHubPathManager.swift` | Auto path correction based on space UX type |

### Builder Registration Location

In `SpaceHubCoordinatorView.swift`:

```swift
AnytypeNavigationView(path: $model.navigationPath, pathChanging: $model.pathChanging) { builder in
    builder.appendBuilder(for: HomeWidgetData.self) { data in
        HomeWidgetsCoordinatorView(data: data)
    }
    builder.appendBuilder(for: EditorScreenData.self) { data in
        EditorCoordinatorView(data: data)
    }
    builder.appendBuilder(for: SpaceHubNavigationItem.self) { _ in
        SpaceHubView(output: model, namespace: namespace)
    }
    builder.appendBuilder(for: SpaceChatCoordinatorData.self) {
        SpaceChatCoordinatorView(data: $0)
    }
    builder.appendBuilder(for: ChatCoordinatorData.self) {
        ChatCoordinatorView(data: $0)
    }
    builder.appendBuilder(for: SpaceInfoScreenData.self) { data in
        // Switch on data cases...
    }
}
```

---

## Common Patterns

### Adding a New Screen Type

1. Create a `Hashable` data struct (e.g., `MyScreenData`)
2. Register builder in `SpaceHubCoordinatorView`:
   ```swift
   builder.appendBuilder(for: MyScreenData.self) { data in
       MyScreenView(data: data)
   }
   ```
3. Add case to `ScreenData` enum if needed for `showScreen()` usage
4. Handle in `showScreen()` method

### Navigating Programmatically

```swift
// Push a new screen
navigationPath.push(EditorScreenData(...))

// Pop back
navigationPath.pop()

// Open singleton screen (widget/chat)
navigationPath.openOnce(HomeWidgetData(spaceId: spaceId))

// Replace current screen
navigationPath.replaceLast(newData)

// Go to space root (keep hub + first screen)
navigationPath.popToFirstOpened()
```

### Changing Spaces

Always use `showScreen()` which handles:
- Validating the space exists
- Building initial path for new space
- Dismissing presented sheets
- Updating `currentSpaceId`
