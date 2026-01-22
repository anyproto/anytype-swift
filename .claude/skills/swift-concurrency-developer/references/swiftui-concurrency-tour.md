# SwiftUI Concurrency Tour - Summary

Context: SwiftUI-focused concurrency overview covering actor isolation, Sendable closures, and how SwiftUI runs work off the main thread.

## Main-Actor Default in SwiftUI

- `View` is `@MainActor` isolated by default; members and `body` inherit isolation
- Swift 6.2 can infer `@MainActor` for all types in a module (new language mode)
- This default simplifies UI code and aligns with UIKit/AppKit `@MainActor` APIs

## Where SwiftUI Runs Code Off the Main Thread

SwiftUI may evaluate some view logic on background threads for performance:
- `Shape` path generation
- `Layout` methods
- `visualEffect` closures
- `onGeometryChange` closures

These APIs often require `Sendable` closures to reflect their runtime semantics.

## Sendable Closures and Data-Race Safety

Accessing `@MainActor` state from a `Sendable` closure is unsafe and flagged by the compiler.

**Solution**: Capture value copies in the closure capture list (e.g., copy a `Bool`)

```swift
// BAD - Accessing MainActor state in Sendable closure
.visualEffect { content, geometryProxy in
    content.opacity(self.isVisible ? 1 : 0)  // Error
}

// GOOD - Capture value copy
let isVisible = self.isVisible
return content.visualEffect { content, geometryProxy in
    content.opacity(isVisible ? 1 : 0)
}
```

## Structuring Async Work with SwiftUI

- SwiftUI action callbacks are synchronous so UI updates can be immediate
- Use `Task` to bridge into async contexts; keep async bodies minimal
- Use state as the boundary: async work updates model/state; UI reacts synchronously

```swift
Button("Load") {
    // Synchronous - UI can update immediately
    isLoading = true

    Task {
        // Async work
        let data = await fetchData()

        // Update state (triggers UI update)
        self.data = data
        isLoading = false
    }
}
```

## Performance-Driven Concurrency

- Offload expensive work from the main actor to avoid hitches
- Keep time-sensitive UI logic (animations, gesture responses) synchronous
- Separate UI code from long-running async work to improve responsiveness and testability

---

**Source**: WWDC SwiftUI Concurrency Sessions
