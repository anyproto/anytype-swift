# Swift 6.2 Concurrency Updates - Summary

## Data-Race Safety Philosophy Change

Swift 6.2 changes the philosophy to **stay single-threaded by default** until you choose to introduce concurrency.

### Before Swift 6.2

```swift
// This would error in earlier Swift 6 versions
@MainActor
final class StickerModel {
    let photoProcessor = PhotoProcessor()

    func extractSticker(_ item: PhotosPickerItem) async throws -> Sticker? {
        // Error: Sending 'self.photoProcessor' risks causing data races
        return await photoProcessor.extractSticker(data: data, with: item.itemIdentifier)
    }
}
```

### In Swift 6.2

```swift
// No longer a data race error - async functions stay on caller's actor
@MainActor
final class StickerModel {
    let photoProcessor = PhotoProcessor()

    func extractSticker(_ item: PhotosPickerItem) async throws -> Sticker? {
        return await photoProcessor.extractSticker(data: data, with: item.itemIdentifier)
    }
}
```

## Isolated Conformances

```swift
protocol Exportable {
    func export()
}

// Works in Swift 6.2 - isolated conformance
extension StickerModel: @MainActor Exportable {
    func export() {
        photoProcessor.exportAsPNG()
    }
}
```

## Main Actor by Default Mode

You can model a program that's entirely single-threaded:

```swift
// Mode to infer main actor by default
final class StickerLibrary {
    static let shared: StickerLibrary = .init()  // No error
}

final class StickerModel {
    let photoProcessor: PhotoProcessor
    var selection: [PhotosPickerItem]
}
```

This eliminates data-race safety errors about:
- Unsafe global and static variables
- Calls to other main actor functions
- And more

## Offloading Work to Background

Use `@concurrent` to explicitly run on the concurrent thread pool:

```swift
class PhotoProcessor {
    var cachedStickers: [String: Sticker]

    func extractSticker(data: Data, with id: String) async -> Sticker {
        if let sticker = cachedStickers[id] {
            return sticker
        }
        let sticker = await Self.extractSubject(from: data)
        cachedStickers[id] = sticker
        return sticker
    }

    // Offload expensive image processing
    @concurrent
    static func extractSubject(from data: Data) async -> Sticker { }
}
```

## How to Use @concurrent

To run a function on a background thread:

1. Make sure the structure or class is `nonisolated`
2. Add `@concurrent` attribute to the function
3. Add `async` keyword if not already asynchronous
4. Add `await` to any callers

```swift
nonisolated struct PhotoProcessor {
    @concurrent
    func process(data: Data) async -> ProcessedPhoto? { ... }
}

// Callers add await
processedPhotos[item.id] = await PhotoProcessor().process(data: data)
```

## Summary

These language changes work together:

1. **Start** by writing code that runs on the main actor by default (no risk of data races)
2. **When using async functions**, they run wherever called from (still no risk)
3. **When ready for concurrency**, use `@concurrent` to offload specific code to background

## Enabling Approachable Concurrency

In Xcode: Swift Compiler - Concurrency settings

In SwiftPM: Use SwiftSettings API in Package.swift

---

**Source**: Swift 6.2 Release Notes and WWDC Sessions
