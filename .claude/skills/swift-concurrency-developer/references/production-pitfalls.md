# Production Concurrency Pitfalls

Real-world Swift Concurrency mistakes that cause data loss, App Store rejections, battery drain, migration nightmares, and duplicate work. Each section includes wrong/correct code, real Anytype codebase examples, and detection commands.

---

## 1. Async For Loops Silently Losing Data

### The Problem

When you iterate over items in an async loop and use `try?` or empty `catch {}`, failures are swallowed silently. Users lose data with zero indication. This is especially dangerous in batch operations like file uploads, sync tasks, or cache warming.

### Wrong

```swift
for item in items {
    try? await service.upload(item)  // Failure = silent data loss
}

for item in items {
    do {
        try await service.process(item)
    } catch {}  // Swallowed - no logging, no retry, no user feedback
}
```

### Correct

```swift
// Option A: Collect errors, report at end
var failures: [(Item, Error)] = []
for item in items {
    do {
        try await service.upload(item)
    } catch {
        failures.append((item, error))
        anytypeAssertionFailure("Upload failed for \(item.id)", info: ["error": error.localizedDescription])
    }
}
if failures.isNotEmpty {
    // Show user feedback, retry, or log
}

// Option B: Use TaskGroup for parallel processing with error collection
try await withThrowingTaskGroup(of: Void.self) { group in
    for item in items {
        group.addTask { try await service.upload(item) }
    }
    try await group.waitForAll()  // Propagates first error
}
```

### Codebase Examples

**`MediaCacheHeatingService.swift:21-25`** - Empty `catch {}` in async loop:
```swift
for fileId in toSchedule {
    do {
        try await fileService.scheduleCacheDownload(fileObjectId: fileId)
        scheduledDownloads.insert(fileId)
    } catch {}  // Acceptable here: fire-and-forget cache heating
}
```
*Nuance*: This is intentionally fire-and-forget. Cache heating is a best-effort optimization - if a download fails, the image just won't be pre-cached. The user will fetch it on demand. This pattern is **acceptable** for non-critical background work.

**`PasteboardTask.swift:81-86`** - `try?` drops file loading errors:
```swift
for itemProvider in fileSlots {
    try Task.checkCancellation()
    let path = try? await itemProvider.loadFileRepresentation(...)
    if let path {
        files.append(PasteboardFile(path: path.relativePath, ...))
    }
}
```
*Risk*: If file loading fails (e.g., permission denied, corrupt data), the file is silently skipped. The paste operation succeeds with fewer items than expected. Users may not notice missing content.

### When Empty Catch Is Acceptable

- **Cache warming / prefetching** - Best-effort, user has fallback path
- **Analytics events** - Non-critical, shouldn't block user flow
- **Cancellation cleanup** - `try? await service.cancel(...)` during teardown

### When Empty Catch Is Dangerous

- **File uploads / sync** - Users expect all items to transfer
- **Data migration** - Partial migration = corrupted state
- **Financial/critical operations** - Silent failure = data loss

### Detection

```bash
# Empty catch blocks in async code
rg "catch\s*\{\s*\}" --type swift Anytype/Sources/ Modules/Services/Sources/

# try? in async calls (review candidates, not all are bugs)
rg "try\? await" --type swift Anytype/Sources/ Modules/Services/Sources/
```

---

## 2. Assuming async = Background Thread

### The Problem

`async` does NOT mean "runs on a background thread." An `async` function inherits its caller's isolation. If called from `@MainActor` context, it runs on the main thread. Heavy computation in an async function on MainActor blocks the UI, causing:
- App Store rejection ("app became unresponsive")
- Janky scrolling and frozen UI
- Watchdog kills on older devices

### Wrong

```swift
@MainActor
final class SearchViewModel: ObservableObject {
    func search(_ query: String) async {
        // WRONG: This runs on the main thread!
        let results = items.filter { $0.matches(query) }  // Heavy computation
        let sorted = results.sorted(by: complexSort)       // Still main thread
        self.results = sorted
    }
}
```

### Correct

```swift
@MainActor
final class SearchViewModel: ObservableObject {
    func search(_ query: String) async {
        // Offload heavy work explicitly
        let results = await Task.detached(priority: .userInitiated) {
            let filtered = items.filter { $0.matches(query) }
            return filtered.sorted(by: complexSort)
        }.value
        self.results = results  // Back on MainActor for UI update
    }
}

// Even better: Use an actor for the heavy work
actor SearchEngine {
    func search(_ query: String, in items: [Item]) -> [Item] {
        items.filter { $0.matches(query) }.sorted(by: complexSort)
    }
}
```

### Codebase Examples

**`ChatMessageBuilder.swift`** - Correct actor pattern:
```swift
actor ChatMessageBuilder: ChatMessageBuilderProtocol, Sendable {
    // Heavy message building runs OFF the main thread
    // because it's an actor (not @MainActor)
}
```
This is the correct approach: CPU-heavy message building is isolated in its own actor, keeping the main thread free.

**Risk areas**: Any `@MainActor @Observable` ViewModel with heavy synchronous computation in an async method. The `await` keyword at the call site makes it *look* like it's offloaded, but it isn't.

### Key Insight

The `async` keyword means "this function can suspend." It does NOT mean "this function runs on a background thread." Where code runs depends entirely on isolation context:

| Context | Where it runs |
|---------|---------------|
| `@MainActor` function | Main thread |
| Custom `actor` function | Cooperative thread pool |
| `nonisolated async` function | Cooperative thread pool |
| `Task.detached { }` | Cooperative thread pool (no inherited context) |
| `Task { }` inside `@MainActor` | Main thread (inherits isolation) |

### Detection

```bash
# Find @MainActor classes doing heavy work in async methods
# Look for sort, filter, map, reduce, compactMap in @MainActor ViewModels
rg "@MainActor" -A 20 --type swift Anytype/Sources/PresentationLayer/ | grep -E "\.(sort|filter|map|reduce|compactMap)\("
```

---

## 3. Ignoring Task Cancellation

### The Problem

When a SwiftUI view disappears, `.task {}` cancels its task. But `for await` loops and long-running operations don't automatically stop unless you check for cancellation. This leads to:
- Wasted CPU/network after the user navigates away
- Battery drain from orphaned background work
- Potential crashes updating deallocated views

### Wrong

```swift
func processLargeDataset() async {
    for item in hugeArray {
        await process(item)  // Continues even after task is cancelled!
    }
}

// No cancellation check in manual polling
func pollForUpdates() async {
    while true {
        let update = await fetchUpdate()
        handleUpdate(update)
        try? await Task.sleep(for: .seconds(5))  // try? swallows CancellationError!
    }
}
```

### Correct

```swift
func processLargeDataset() async throws {
    for item in hugeArray {
        try Task.checkCancellation()  // Throws if cancelled
        await process(item)
    }
}

// Proper cancellation in polling
func pollForUpdates() async {
    while !Task.isCancelled {
        let update = await fetchUpdate()
        handleUpdate(update)
        try? await Task.sleep(for: .seconds(5))
        // Task.sleep throws CancellationError, loop condition catches the rest
    }
}
```

### Codebase Examples

**`ChatViewModel.swift`** - 9 `for await` loops, all SAFE:
```swift
func startSubscriptions() async {
    async let permissionsSub: () = subscribeOnPermissions()
    async let participantsSub: () = subscribeOnParticipants()
    // ... 8 total subscriptions
    _ = await (permissionsSub, participantsSub, ...)
}

// Each subscription uses for await:
private func subscribeOnParticipants() async {
    for await participants in participantSubscription.participantsPublisher.values {
        self.participants = participants
        await updateMessages()
    }
}
```
*Why this is safe*: `startSubscriptions()` is called from `.task { await model.startSubscriptions() }` in `ChatView.swift`. The `.task` modifier creates a structured task that is cancelled when the view disappears. Cancellation propagates through `async let` to each `for await` loop, which terminates because `AsyncSequence` iteration respects cooperative cancellation. **No explicit `Task.isCancelled` check is needed here.**

**`HangedObjectsMonitor.swift:40-57`** - Manual task with cancellation:
```swift
private func startTimer() {
    timer?.cancel()
    timer = Task { [weak self] in
        while !Task.isCancelled {  // Explicit cancellation check
            guard let self, let startTime = self.startTime else {
                return  // Exits if self is deallocated
            }
            // ... timer logic
            try? await Task.sleep(for: .seconds(1))
        }
    }
}
```
*Why explicit check is needed*: This is an unstructured `Task { }` stored in a property. It's NOT tied to SwiftUI's `.task` modifier, so cancellation must be checked manually. The `weak self` pattern provides an additional safety net.

### When You Need Explicit Cancellation Checks

| Pattern | Needs explicit check? | Why |
|---------|----------------------|-----|
| `for await` under `.task` modifier | No | Structured concurrency propagates cancellation |
| `for await` under stored `Task { }` | Yes | Unstructured, won't auto-cancel |
| `while` loop with `Task.sleep` | Yes | Sleep alone isn't enough if `try?` swallows error |
| Heavy computation loop | Yes | No suspension points to check cancellation |
| `Task.detached { }` | Yes | Fully unstructured, no parent to cancel it |

### Detection

```bash
# for-await loops in ViewModels (review: are they under .task or stored Task?)
rg "for await" --type swift Anytype/Sources/PresentationLayer/

# while loops without cancellation checks
rg "while true|while !Task" --type swift Anytype/Sources/

# Stored tasks (potential unstructured tasks needing manual cancellation)
rg "private var.*Task<" --type swift Anytype/Sources/
```

---

## 4. Manual Migration Pitfalls (@preconcurrency and DispatchQueue+async mixing)

### The Problem

During incremental Swift 6 migration, codebases accumulate `@preconcurrency`, `nonisolated(unsafe)`, and bridge patterns mixing `DispatchQueue` with `async/await`. These are necessary escape hatches, but they:
- Hide real data races behind compiler silencing
- Create confusing execution contexts (which thread am I on?)
- Make future migration harder as debt compounds
- Can cause subtle ordering bugs at DispatchQueue/async boundaries

### Wrong

```swift
// Silencing the compiler without understanding the race
@preconcurrency import SomeFramework
nonisolated(unsafe) var sharedState: [String] = []  // "Trust me" = famous last words

// Mixing dispatch and async without clear boundaries
func doWork() {
    DispatchQueue.main.async {
        Task {
            await self.asyncWork()
            DispatchQueue.global().async {
                // What thread are we on? Nobody knows.
                self.processResult()
            }
        }
    }
}
```

### Correct

```swift
// Document WHY @preconcurrency is needed and plan removal
@preconcurrency import LegacyFramework  // TODO: IOS-XXXX - Remove when LegacyFramework adds Sendable
// Safety invariant: sharedState is only accessed from MainActor context
nonisolated(unsafe) var sharedState: [String] = []

// Clean bridge: one direction, clear boundary
func doWork() async {
    let result = await asyncWork()
    await MainActor.run {
        processResult(result)
    }
}
```

### Codebase Examples

**Migration debt scale** (as of codebase snapshot):
- `@preconcurrency import` — 24 occurrences in `Anytype/Sources/`
- `nonisolated(unsafe)` — ~30 occurrences across the codebase (mostly in generated Protobuf code)
- `DispatchQueue` + `async` mixing — ~21 files in `Anytype/Sources/`

**`PasteboardBlockService.swift`** - DispatchQueue/async bridge:
```swift
@preconcurrency import Foundation

private func paste(..., completion: @escaping @MainActor (...) -> Void) {
    let workItem = DispatchWorkItem { handleLongOperation() }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)

    let task = Task { @Sendable in
        let pasteResult = try? await pasteboardTask.start()
        DispatchQueue.main.async {
            workItem.cancel()
            completion(pasteResult)
        }
    }
}
```
*Analysis*: This bridges callback-based API (`completion`) with async/await (`pasteboardTask.start()`). The `DispatchQueue.main.async` inside a `Task` is needed because the completion handler interface requires `@MainActor` delivery, but the task runs off-main. This is a valid bridge pattern during migration, but should eventually become a pure async function.

### Migration Tracking Checklist

When reviewing code with these patterns:

1. **`@preconcurrency import`** - Is the imported framework now Sendable-compliant? If yes, remove.
2. **`nonisolated(unsafe)`** - Is there a documented safety invariant? Is the invariant still true?
3. **`DispatchQueue` inside `Task`** - Can this be replaced with `await MainActor.run { }`?
4. **Completion handler + Task** - Can the entire call chain become async?

### Detection

```bash
# @preconcurrency imports (should decrease over time)
rg "@preconcurrency import" --type swift Anytype/Sources/

# nonisolated(unsafe) usage
rg "nonisolated\(unsafe\)" --type swift

# DispatchQueue usage inside async contexts
rg "DispatchQueue\." --type swift Anytype/Sources/ Modules/Services/Sources/

# Files mixing both patterns (highest migration priority)
rg -l "DispatchQueue" --type swift Anytype/Sources/ | xargs rg -l "async "
```

---

## 5. Task Inside onAppear vs .task Modifier

### The Problem

Creating a `Task { }` inside `.onAppear` is an unstructured task that:
- Is NOT cancelled when the view disappears (memory leak, wasted work)
- Can fire multiple times if the view re-appears (duplicate API calls)
- Has no parent task for structured cancellation propagation

The `.task` modifier is purpose-built for SwiftUI:
- Automatically cancelled on view disappear
- Runs once per view lifetime (or per `id` change with `.task(id:)`)
- Supports structured concurrency

### Wrong

```swift
struct ProfileView: View {
    var body: some View {
        content
            .onAppear {
                Task {
                    await model.loadProfile()  // Leaked task, fires on every appear
                }
            }
    }
}
```

### Correct

```swift
struct ProfileView: View {
    var body: some View {
        content
            .task {
                await model.loadProfile()  // Cancelled on disappear, runs once
            }
    }
}

// For work that should re-run when a value changes:
struct DetailView: View {
    var body: some View {
        content
            .task(id: selectedId) {
                await model.loadDetail(id: selectedId)  // Re-runs when id changes
            }
    }
}
```

### Codebase Examples (Correct Patterns)

**`ChatView.swift`** - Correct use of `.task` and `.throwingTask`:
```swift
.onAppear {
    model.keyboardDismiss = keyboardDismiss  // Sync setup only
    model.configureProvider(chatActionProvider)
    model.onAppear()
}
.task {
    await model.startSubscriptions()  // Async work in .task, not onAppear
}
.throwingTask {
    try await model.subscribeOnMessages()  // Custom modifier wrapping .task
}
.task(id: model.photosItemsTask) {
    await model.updatePickerItems()  // Re-runs when task ID changes
}
```
*Key insight*: `onAppear` is used for synchronous setup only (assigning environment values, calling sync methods). All async work goes through `.task` or `.throwingTask`.

**`throwingTask` modifier** (`AsyncThrowsTask.swift`) - Wraps `.task` with error handling:
```swift
func body(content: Content) -> some View {
    content
        .task {
            do {
                try await action()
            } catch {
                toast = ToastBarData(error.localizedDescription, type: .failure)
            }
        }
}
```
This is a convenience wrapper that catches errors from `.task` and shows a toast. It preserves all `.task` lifecycle benefits (auto-cancellation on disappear).

**`taskWithMemoryScope` modifier** (`TaskWithMemoryScope.swift`) - For tasks that should survive view re-creation:
```swift
@MainActor
private final class TaskWithMemoryScopeViewModel: ObservableObject {
    private var task: Task<Void, Never>?

    func startIfNeeded() {
        guard task.isNil else { return }
        task = Task { [action] in await action() }
    }

    deinit { task?.cancel() }  // Cancelled when ViewModel is deallocated
}
```
*Use case*: When you need the task to survive SwiftUI view struct re-creation but still clean up on deallocation. Uses `@StateObject` for stable identity. The `deinit` ensures cleanup.

### When onAppear Is Correct

```swift
// Synchronous setup - no async work
.onAppear {
    model.keyboardDismiss = keyboardDismiss
    model.configureProvider(chatActionProvider)
    model.onAppear()  // Sync method, not async
}

// Analytics tracking (fire and forget, no cleanup needed)
.onAppear {
    AnytypeAnalytics.instance().logScreenView()
}
```

### Quick Decision Guide

| Need | Use |
|------|-----|
| Run async work tied to view lifecycle | `.task { }` |
| Run async work when a value changes | `.task(id: value) { }` |
| Run throwing async work with error toast | `.throwingTask { }` |
| Run async work that survives view re-creation | `.taskWithMemoryScope { }` |
| Synchronous setup on appear | `.onAppear { }` |
| Fire-and-forget analytics | `.onAppear { }` (sync call) |

### Detection

```bash
# Task inside onAppear (review candidates)
rg "\.onAppear" -A 5 --type swift Anytype/Sources/PresentationLayer/ | grep "Task {"

# Verify .task usage is correct (should be more common than Task-in-onAppear)
rg "\.task\s*\{" --type swift Anytype/Sources/PresentationLayer/ -c
rg "\.throwingTask" --type swift Anytype/Sources/PresentationLayer/ -c
```

---

## Summary

| Pitfall | Production Impact | Severity |
|---------|------------------|----------|
| Silent error swallowing in async loops | Data loss, incomplete operations | High |
| async != background thread | App Store rejection, frozen UI | Critical |
| Ignoring task cancellation | Battery drain, wasted resources | Medium-High |
| Migration debt accumulation | Hidden data races, harder future migration | Medium |
| Task in onAppear vs .task | Duplicate calls, memory leaks | Medium |

---

*Attribution*: Patterns identified from production Anytype iOS codebase analysis. Detection commands are review candidates - not all matches are bugs. Always verify context before changing code.*
