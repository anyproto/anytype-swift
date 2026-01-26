# Demystify SwiftUI Performance (WWDC23) - Summary

Context: WWDC23 session on building a mental model for SwiftUI performance and triaging hangs/hitches.

## Performance Loop

- Measure -> Identify -> Optimize -> Re-measure
- Focus on concrete symptoms (slow navigation, broken animations, spinning cursor)

## Update Process Internals

SwiftUI's view update follows a three-step process:

```
┌─────────────────────────────────────────────────────────────┐
│                     UPDATE PROCESS                          │
├─────────────────────────────────────────────────────────────┤
│  1. PRODUCE VIEW VALUE                                      │
│     └── Stored properties + initial dynamic property values │
│                                                             │
│  2. UPDATE DYNAMIC PROPERTIES                               │
│     └── Replace initial values with current graph values    │
│     └── @State, @Binding, @Environment, @Query, etc.        │
│                                                             │
│  3. RUN BODY                                                │
│     └── Produce child views                                 │
│     └── Recurse only for children with changed values       │
└─────────────────────────────────────────────────────────────┘
```

**Key insight**: The update only recurses into child views that have *actually changed* (either their stored properties or dynamic property dependencies changed).

### What Triggers an Update

A view's `body` is re-evaluated when:
- Its stored properties (passed from parent) change
- Any dynamic property it depends on changes (`@State`, `@Binding`, `@Environment`, `@ObservedObject`, `@Query`, etc.)

## Dependencies and Updates

- Views form a dependency graph; dynamic properties are a frequent source of updates
- Use `Self._printChanges()` in debug only to inspect extra dependencies
- Eliminate unnecessary dependencies by extracting views or narrowing state
- Consider `@Observable` for more granular property tracking

## Debugging with `_printChanges()`

### LLDB Workflow

1. Set a breakpoint in the view's `body` property
2. When breakpoint hits, type in LLDB console:
   ```
   po Self._printChanges()
   ```
3. Analyze the output to understand what triggered the update

### Output Meanings

| Output | Meaning |
|--------|---------|
| `@Self` | View value changed (stored properties passed from parent) |
| `_propertyName` | That specific dynamic property changed |
| Multiple items | Multiple dependencies changed simultaneously |

### Example Debugging Session

```swift
struct DogView: View {
    let dog: Dog
    @Environment(\.locale) private var locale

    var body: some View {
        // Set breakpoint here
        Text(dog.name)
    }
}
```

LLDB output examples:
- `@self` → Parent passed a new `dog` value
- `_locale` → Environment's locale changed
- `@self, _locale` → Both changed

### WARNING: Never Ship to App Store

**`_printChanges()` has runtime impact and is for debugging only.**

- Use only during development
- Remove before shipping
- Consider wrapping in `#if DEBUG` if keeping temporarily:

```swift
var body: some View {
    #if DEBUG
    let _ = Self._printChanges()
    #endif

    Text(dog.name)
}
```

## Common Causes of Slow Updates

- Expensive view bodies (string interpolation, filtering, formatting)
- Dynamic property instantiation and state initialization in `body`
- Slow identity resolution in lists/tables
- Hidden work: bundle lookups, heap allocations, repeated string construction

## Constant View Count Pattern (CRITICAL for Lists)

**Formula**: `total rows = elements × views per element`

For List/Table performance, each `ForEach` element must produce a **constant number** of views. If views-per-element varies, SwiftUI must build ALL views upfront to count rows.

### BAD: Variable View Count (0 or 1)

```swift
// ❌ BAD - Conditional produces 0 or 1 views
ForEach(dogs) { dog in
    if dog.likesBall {
        DogCell(dog: dog)
    }
}
// Forces SwiftUI to build ALL DogCells to count rows
```

### BAD: Unknown View Count

```swift
// ❌ BAD - AnyView hides structure, count unknown
ForEach(dogs) { dog in
    AnyView(conditionalContent(for: dog))
}
// SwiftUI cannot predict row count
```

### OK But Costly: Inline Filtering

```swift
// ⚠️ OK but inefficient - O(n) filter runs every render
ForEach(dogs.filter { $0.likesBall }) { dog in
    DogCell(dog: dog)
}
// Works correctly, but recomputes filter on every body evaluation
```

### GOOD: Pre-filtered Collection

```swift
// ✅ GOOD - Cache filter result in model
ForEach(model.ballLovingDogs) { dog in
    DogCell(dog: dog)  // Always 1 view per element
}

@Observable class DogModel {
    var dogs: [Dog] = []
    var ballLovingDogs: [Dog] {
        dogs.filter { $0.likesBall }
    }
}
```

### Sectioned Lists Are OK

Nested `ForEach` for sections is fine because each section's element count is known:

```swift
// ✅ GOOD - Section structure is constant
ForEach(sections) { section in
    Section(header: Text(section.title)) {
        ForEach(section.items) { item in
            ItemRow(item: item)  // Constant: 1 view per item
        }
    }
}
```

## Dependency Reduction Patterns

### Extract Only Needed Data

```swift
// ❌ BAD - View depends on entire dog object
struct DogCard: View {
    let dog: Dog  // Any dog property change triggers update

    var body: some View {
        ScalableDogImage(dog: dog)
    }
}

// ✅ GOOD - View depends only on image
struct DogCard: View {
    let dog: Dog

    var body: some View {
        ScalableDogImage(image: dog.image)  // Only image changes trigger child update
    }
}
```

### Extract Subviews

```swift
// ❌ BAD - All inline, entire view rebuilds
struct DogProfile: View {
    @State var dog: Dog

    var body: some View {
        VStack {
            Text(dog.name).font(.title)
            Text(dog.breed).font(.caption)
            DogStats(dog: dog)
        }
    }
}

// ✅ GOOD - Extracted header isolates name/breed updates
struct DogProfile: View {
    @State var dog: Dog

    var body: some View {
        VStack {
            DogHeader(name: dog.name, breed: dog.breed)
            DogStats(dog: dog)
        }
    }
}

struct DogHeader: View {
    let name: String
    let breed: String

    var body: some View {
        VStack {
            Text(name).font(.title)
            Text(breed).font(.caption)
        }
    }
}
```

## Avoid Slow Initialization in View Bodies

### BAD: Synchronous Fetch

```swift
// ❌ BAD - Model init fetches data synchronously
struct DogListView: View {
    @StateObject var model = DogModel()  // init() fetches synchronously

    var body: some View {
        List(model.dogs) { DogRow(dog: $0) }
    }
}
```

### GOOD: Async with .task

```swift
// ✅ GOOD - Defer async work to .task
struct DogListView: View {
    @StateObject var model = DogModel()  // init() is lightweight

    var body: some View {
        List(model.dogs) { DogRow(dog: $0) }
            .task {
                await model.fetch()  // Async, off main thread
            }
    }
}
```

## Lists and Tables Identity Rules

- Stable identity is critical for performance and animation
- Ensure a constant number of views per element in `ForEach`
- Avoid inline filtering in `ForEach`; pre-filter and cache collections
- Avoid `AnyView` in list rows; it hides identity and increases cost
- Flatten nested `ForEach` when possible to reduce overhead

## iOS 17 / macOS Sonoma Changes

### Under-the-Hood Optimizations

iOS 17 and macOS Sonoma include significant internal optimizations for:
- Filtering in lists
- Scroll performance
- Table rendering

### New Table ForEach Initializer

A streamlined `Table` initializer that enforces constant row count patterns:

```swift
// New in iOS 17 - back-deploys to earlier versions!
Table(data) { item in
    TableRow(item) {
        Text(item.name)
        Text(item.status)
    }
}
```

### Semantic Change: Table Row Identity

**Important behavior change in iOS 17:**

Previously, table rows were identified by `TableRow` value.
Now, rows are identified by the **ForEach element ID**.

```swift
// Before iOS 17: TableRow(item) - item itself was identity
// iOS 17+: ForEach element's id property is the identity

ForEach(items, id: \.id) { item in  // ← id: \.id is now the row identity
    TableRow(item)
}
```

**Action**: Ensure your `ForEach` uses stable, unique IDs for table rows.

## Debugging Aids

- Use Instruments for hangs and hitches
- Use `_printChanges` to validate dependency assumptions during debug
- Focus on concrete symptoms rather than abstract metrics
- Profile on actual devices, not just Simulator

---

**Source**: [WWDC23 - Demystify SwiftUI Performance](https://developer.apple.com/videos/play/wwdc2023/10160/)
