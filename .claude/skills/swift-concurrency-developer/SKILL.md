# Swift Concurrency Developer (Smart Router)

## Purpose
Expert guidance on Swift's concurrency system using the "Office Building" mental model from [Fucking Approachable Swift Concurrency](https://fuckingapproachableswiftconcurrency.com).

## When Auto-Activated
- Working with actors, isolation, Sendable, TaskGroups
- Keywords: `actor`, `isolation`, `Sendable`, `TaskGroup`, `nonisolated`, `async let`
- Fixing concurrency warnings or data race issues

## Core Mental Model: The Office Building

Think of your app as an office building where **isolation domains** are private offices with locks:

| Concept | Office Analogy | Swift |
|---------|----------------|-------|
| **MainActor** | Front desk (handles all UI) | `@MainActor` |
| **actor** | Department offices (Accounting, Legal) | `actor BankAccount { }` |
| **nonisolated** | Hallways (shared space) | `nonisolated func name()` |
| **Sendable** | Photocopies (safe to share) | `struct User: Sendable` |
| **Non-Sendable** | Original documents (stay in one office) | `class Counter { }` |

**Key insight**: You can't barge into someone's office. You knock (`await`) and wait.

## Quick Patterns

### Async/Await
```swift
func fetchUser(id: Int) async throws -> User {
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
}
```

### Parallel Work with async let
```swift
async let avatar = fetchImage("avatar.jpg")
async let banner = fetchImage("banner.jpg")
return Profile(avatar: try await avatar, banner: try await banner)
```

### Tasks
```swift
// SwiftUI - cancels when view disappears
.task { avatar = await downloadAvatar() }

// Manual task (inherits actor context)
Task { await saveProfile() }
```

### TaskGroup for Dynamic Parallel Work
```swift
try await withThrowingTaskGroup(of: Void.self) { group in
    group.addTask { avatar = try await downloadAvatar() }
    group.addTask { bio = try await fetchBio() }
    try await group.waitForAll()
}
```

### Actors
```swift
actor BankAccount {
    var balance: Double = 0
    func deposit(_ amount: Double) { balance += amount }

    // No await needed - can access directly inside actor
    nonisolated func bankName() -> String { "Acme Bank" }
}

await account.deposit(100)  // Must await from outside
let name = account.bankName()  // No await needed
```

### Sendable Types
```swift
// Automatically Sendable - value type
struct User: Sendable {
    let id: Int
    let name: String
}

// Thread-safe class with internal synchronization
final class ThreadSafeCache: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: Data] = [:]
}
```

## Approachable Concurrency (Swift 6.2+)

Two build settings that simplify the mental model:

```
SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor
SWIFT_APPROACHABLE_CONCURRENCY = YES
```

```swift
// Runs on MainActor (default)
func updateUI() async { }

// Runs on background (opt-in)
@concurrent func processLargeFile() async { }
```

## Common Mistakes

### 1. Thinking async = background
```swift
// WRONG: Still blocks main thread!
@MainActor func slowFunction() async {
    let result = expensiveCalculation()  // Synchronous = blocking
}

// CORRECT: Use @concurrent for CPU-heavy work
@concurrent func processData() async -> Result { ... }
```

### 2. Creating too many actors
Most things can live on MainActor. Only create actors when you have shared mutable state that can't be on MainActor.

### 3. Using MainActor.run unnecessarily
```swift
// WRONG
await MainActor.run { self.data = data }

// CORRECT - annotate the function
@MainActor func loadData() async { self.data = await fetchData() }
```

### 4. Blocking the cooperative thread pool
Never use `DispatchSemaphore`, `DispatchGroup.wait()` in async code. Risks deadlock.

### 5. Creating unnecessary Tasks
```swift
// WRONG - unstructured
Task { await fetchUsers() }
Task { await fetchPosts() }

// CORRECT - structured concurrency
async let users = fetchUsers()
async let posts = fetchPosts()
await (users, posts)
```

### 6. Making everything Sendable
Not everything needs to cross boundaries. Ask if data actually moves between isolation domains.

## Quick Reference

| Keyword | Purpose |
|---------|---------|
| `async` | Function can pause |
| `await` | Pause here until done |
| `Task { }` | Start async work, inherits context |
| `Task.detached { }` | Start async work, no context |
| `@MainActor` | Runs on main thread |
| `actor` | Type with isolated mutable state |
| `nonisolated` | Opts out of actor isolation |
| `Sendable` | Safe to pass between isolation domains |
| `@unchecked Sendable` | Trust me, it's thread-safe |
| `@concurrent` | Always run on background (Swift 6.2+) |
| `async let` | Start parallel work |
| `TaskGroup` | Dynamic parallel work |

## When the Compiler Complains

Trace the isolation: Where did it come from? Where is code trying to run? What data crosses a boundary?

The answer is usually obvious once you ask the right question.

## Further Reading
- Source: [Fucking Approachable Swift Concurrency](https://fuckingapproachableswiftconcurrency.com)
- [Matt Massicotte's Blog](https://www.massicotte.org/)
- [Swift Concurrency Documentation](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/)

---
**Navigation**: This skill provides concurrency mental models. For general Swift/iOS patterns, see `ios-dev-guidelines`.
