---
name: swiftui-performance-developer
description: Audit and improve SwiftUI runtime performance through code review and Instruments guidance. Use for diagnosing slow rendering, janky scrolling, excessive view updates, or layout thrash in SwiftUI apps.
---

# SwiftUI Performance Developer (Smart Router)

## Purpose
Audit SwiftUI view performance through code review and provide guidance for Instruments profiling when needed.

## When Auto-Activated
- Diagnosing slow rendering, janky scrolling, high CPU/memory
- Excessive view updates or layout thrash
- Keywords: performance, slow, jank, hitch, laggy, stuttering, CPU, memory, update

## Workflow Decision Tree

1. **Code provided** -> Start with Code-First Review
2. **Only symptoms described** -> Ask for code/context, then Code-First Review
3. **Code review inconclusive** -> Guide user to profile with Instruments

## Code-First Review Focus

Look for these common performance issues:

### View Invalidation Storms
```swift
// BAD - Broad state triggers all views
@Observable class Model {
    var items: [Item] = []
}

// GOOD - Granular per-item state
@Observable class ItemModel {
    var isFavorite: Bool
}
```

### Unstable Identity in Lists
```swift
// BAD - id churn causes full re-render
ForEach(items, id: \.self) { item in Row(item) }

// GOOD - Stable identity
ForEach(items, id: \.id) { item in Row(item) }
```

### Heavy Work in `body`
```swift
// BAD - Allocation every render
var body: some View {
    let formatter = NumberFormatter()  // slow
    Text(formatter.string(from: value))
}

// GOOD - Cached formatter
static let formatter = NumberFormatter()
var body: some View {
    Text(Self.formatter.string(from: value))
}
```

### Sorting/Filtering in ForEach
```swift
// BAD - Re-sorts every body eval
ForEach(items.sorted(by: sortRule)) { Row($0) }

// GOOD - Pre-sorted collection
let sortedItems = items.sorted(by: sortRule)
ForEach(sortedItems) { Row($0) }
```

### Large Images Without Downsampling
```swift
// BAD - Decodes full resolution on main thread
Image(uiImage: UIImage(data: data)!)

// GOOD - Downsample off main thread first
```

## Common Code Smells

| Pattern | Problem | Fix |
|---------|---------|-----|
| `NumberFormatter()` in body | Allocation per render | Static cached formatter |
| `.filter { }` in ForEach | Recomputes every render | Pre-filter, cache result |
| `id: \.self` on non-stable values | Identity churn | Use stable ID property |
| `UUID()` per render | New identity every time | Store ID in model |
| `GeometryReader` deep in tree | Layout thrash | Move up or use fixed sizes |

## Instruments Profiling Guidance

When code review is inconclusive, guide user to profile:

1. **Record**: Product > Profile, SwiftUI template (Release build)
2. **Reproduce**: Exact interaction (scroll, navigate, animate)
3. **Capture**: SwiftUI timeline + Time Profiler
4. **Analyze**:
   - "Long View Body Updates" (orange >500us, red >1000us)
   - "Hitches" lane for frame misses
   - Time Profiler call tree for hot frames

Ask user for:
- Trace export or screenshots
- Device/OS/build configuration

## Remediation Checklist

- [ ] Narrow state scope (`@State`/`@Observable` closer to leaf views)
- [ ] Stabilize identities for `ForEach` and lists
- [ ] Move heavy work out of `body` (precompute, cache, `@State`)
- [ ] Use `equatable()` for expensive subtrees
- [ ] Downsample images before rendering
- [ ] Reduce layout complexity or use fixed sizing

## References

For detailed WWDC guidance:
- `references/demystify-swiftui-performance-wwdc23.md`
- `references/optimizing-swiftui-performance-instruments.md`
- `references/understanding-improving-swiftui-performance.md`

## Related Skills

- **ios-dev-guidelines** -> General Swift/iOS patterns
- **swiftui-patterns-developer** -> View structure and composition

---

**Navigation**: This skill provides SwiftUI performance audit patterns. For general iOS development, see `ios-dev-guidelines`.

**Attribution**: Patterns adapted from [Dimillian/Skills](https://github.com/Dimillian/Skills) repository.
