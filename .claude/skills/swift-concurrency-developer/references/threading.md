# Threading

Understanding how Swift Concurrency manages threads and execution contexts.

## Core Concepts

### What is a Thread?

System-level resource that runs instructions. High overhead for creation and switching. Swift Concurrency abstracts thread management away.

### Tasks vs Threads

**Tasks** are units of async work, not tied to specific threads. Swift dynamically schedules tasks on available threads from a cooperative pool.

**Key insight**: No direct relationship between one task and one thread.

> **Course Deep Dive**: This topic is covered in detail in [Lesson 7.1: How Threads relate to Tasks](https://www.swiftconcurrencycourse.com?utm_source=github&utm_medium=agent-skill&utm_campaign=lesson-reference)

**Important (Swift 6+)**: Avoid using `Thread.current` inside async contexts. In Swift 6 language mode, `Thread.current` is unavailable from asynchronous contexts and will fail to compile. Prefer reasoning in terms of isolation domains; use Instruments and the debugger to observe execution when needed.

## Cooperative Thread Pool

Swift creates only as many threads as CPU cores. Tasks share these threads efficiently.

### How it works

1. **Limited threads**: Number matches CPU cores
2. **Task scheduling**: Tasks scheduled onto available threads
3. **Suspension**: At `await`, task suspends, thread freed for other work
4. **Resumption**: Task resumes on any available thread (not necessarily the same one)

```swift
func example() async {
    print("Started on: \(Thread.current)")
    
    try await Task.sleep(for: .seconds(1))
    
    print("Resumed on: \(Thread.current)") // Likely different thread
}
```

### Benefits over GCD

**Prevents thread explosion**:
- No excessive thread creation
- No high memory overhead from idle threads
- No excessive context switching
- No priority inversion

**Better performance**:
- Fewer threads = less context switching
- Continuations instead of blocking
- CPU cores stay busy efficiently

## Thread Explosion: The GCD Problem

Understanding why Swift Concurrency exists requires understanding GCD's fundamental weakness.

### How GCD spawns threads

When GCD work blocks (waiting for lock, semaphore, I/O), the system spawns new threads to maintain parallelism:

```
Initial state: 6 threads (matching 6 CPU cores)

Thread 1 blocks on semaphore → System spawns Thread 7
Thread 2 blocks on lock      → System spawns Thread 8
Thread 3 blocks on I/O       → System spawns Thread 9
...continues until thread explosion
```

**Real example**: 100 concurrent feed updates on a 6-core iPhone could create **16x overcommit** (96+ threads for 6 cores).

### Memory overhead of blocked threads

Each blocked thread consumes resources even while doing nothing:

- **Stack memory**: Typically 512KB per thread
- **Kernel structures**: Thread state, scheduling data
- **Locks held**: Memory pressure from synchronization primitives
- **Page table entries**: Virtual memory overhead

100 blocked threads = 50MB+ of memory just for stacks.

### Scheduling overhead

More threads means more context switching:

- **Direct cost**: Saving/restoring registers, TLB flushes
- **Cache pollution**: Each context switch invalidates CPU caches
- **Time-sharing overhead**: More threads = less time per thread = more frequent switches
- **Priority inversion**: Low-priority threads holding resources needed by high-priority threads

### Why Swift Concurrency solves this

Instead of blocking threads and spawning more, tasks **suspend** and **yield** the thread:

```swift
// GCD: Thread blocks, system spawns another
semaphore.wait() // ❌ Thread blocked

// Swift Concurrency: Task suspends, thread freed
await someAsyncWork() // ✅ Thread available for other work
```

## Continuations: The Suspension Mechanism

When a task suspends, Swift creates a **continuation** - a lightweight object that tracks where to resume.

### How continuations work

```
Task executing → hits await → saves state to continuation → thread freed

Thread picks up work → finds ready continuation → resumes from saved state
```

**Key insight**: Switching between continuations is like a function call. Much cheaper than a full thread context switch.

### Continuation vs context switch

| Operation | Cost |
|-----------|------|
| Function call | ~1-5 nanoseconds |
| Continuation switch | ~10-100 nanoseconds |
| Thread context switch | ~1000-10000 nanoseconds |

Continuations are 10-100x cheaper than thread context switches.

### Stack frame mechanics

Async functions use a hybrid stack model:

- **Immediate values**: Stored on thread stack (fast)
- **Values across suspension**: Stored in async frame on heap
- **Async calls**: Replace stack frame (not add to it)

```swift
func processData() async {
    let temp = 42           // Thread stack (fast)
    await networkCall()     // temp moved to heap if needed across await
    print(temp)             // Restored from heap
}
```

**Benefit**: Swift can still efficiently call C/Objective-C code because synchronous calls use normal stack semantics.

## Runtime Contract

The cooperative thread pool has a **critical contract**: threads will always make forward progress.

### Safe primitives (compiler-enforced)

These primitives are designed for Swift Concurrency and maintain the contract:

- `await` - Suspends task, frees thread
- Actors - Serialize access without blocking
- Task groups - Structured concurrency with proper suspension
- `async let` - Parallel child tasks

```swift
// ✅ Safe: Thread freed during suspension
let data = await fetchData()

// ✅ Safe: Actor serializes without blocking callers
await account.deposit(100)
```

### Cautiously safe primitives

These can be used for **tight critical sections** that complete quickly:

- `os_unfair_lock` - Fast, non-recursive lock
- `NSLock` - Standard mutex
- `Mutex` (iOS 18+) - Modern synchronization

```swift
// ✅ Safe for very short critical sections
mutex.withLock {
    count += 1  // Microseconds, not milliseconds
}
```

**Rule**: Only use for operations that complete in microseconds, never for I/O or complex computation.

### Unsafe primitives (violate contract)

These **hide dependencies from the runtime** and can cause deadlocks:

- `DispatchSemaphore` - Blocks thread, runtime unaware
- `pthread_cond_wait` / `NSCondition` - Same problem
- `DispatchGroup.wait()` - Blocks until group completes

```swift
// ❌ DANGEROUS: Runtime doesn't know thread is waiting
let semaphore = DispatchSemaphore(value: 0)
Task {
    await doWork()
    semaphore.signal()
}
semaphore.wait() // Thread blocked, runtime may deadlock
```

**Why it's dangerous**: The runtime assumes all cooperative pool threads can make progress. If they're all blocked on semaphores waiting for signals that need cooperative pool threads to send, **deadlock**.

### Debugging contract violations

Use this environment variable to catch blocking calls:

```
LIBDISPATCH_COOPERATIVE_POOL_STRICT=1
```

When set, the runtime will assert/crash if code blocks the cooperative thread pool. Use during development to catch violations early.

## Task Dependency Tracking

The runtime tracks task dependencies to make scheduling decisions.

### Explicit dependencies

```swift
// Continuation: runtime knows task waits for this
let result = await asyncOperation()

// Task group: runtime knows parent waits for children
await withTaskGroup(of: Int.self) { group in
    group.addTask { await fetchA() }
    group.addTask { await fetchB() }
}
```

### Why dependency tracking matters

When the runtime knows dependencies, it can:

- **Prioritize correctly**: Boost tasks that high-priority tasks wait on
- **Avoid priority inversion**: Give blocked work the priority it needs
- **Schedule efficiently**: Run ready work on available threads

Semaphores hide dependencies, so the runtime **cannot** make these optimizations.

## Threading Mindset → Isolation Mindset

### Old way (GCD)

```swift
// Thinking about threads
DispatchQueue.main.async {
    // Update UI on main thread
}

DispatchQueue.global(qos: .background).async {
    // Heavy work on background thread
}
```

### New way (Swift Concurrency)

```swift
// Thinking about isolation domains
@MainActor
func updateUI() {
    // Runs on main actor (usually main thread)
}

func heavyWork() async {
    // Runs on any available thread in pool
}
```

### Think in isolation domains

**Don't ask**: "What thread should this run on?"

**Ask**: "What isolation domain should own this work?"

- `@MainActor` for UI updates
- Custom actors for specific state
- Nonisolated for general async work

### Provide hints, not commands

```swift
Task(priority: .userInitiated) {
    await doWork()
}
```

You're describing the nature of work, not assigning threads. Swift optimizes execution.

> **Course Deep Dive**: This topic is covered in detail in [Lesson 7.2: Getting rid of the "Threading Mindset"](https://www.swiftconcurrencycourse.com?utm_source=github&utm_medium=agent-skill&utm_campaign=lesson-reference)

## Suspension Points

### What is a suspension point?

Moment where task **may** pause to allow other work. Marked by `await`.

```swift
let data = await fetchData() // Potential suspension
```

**Critical**: `await` marks *possible* suspension, not guaranteed. If operation completes synchronously, no suspension occurs.

### Why suspension points matter

1. **Code may pause unexpectedly** - resumes later, possibly different thread
2. **State can change** - mutable state may be modified during suspension
3. **Actor reentrancy** - other tasks can access actor during suspension

### Actor reentrancy example

```swift
actor BankAccount {
    private var balance: Int = 0
    
    func deposit(amount: Int) async {
        balance += amount
        print("Balance: \(balance)")
        
        await logTransaction(amount) // ⚠️ Suspension point
        
        balance += 10 // Bonus
        print("After bonus: \(balance)")
    }
    
    func logTransaction(_ amount: Int) async {
        try? await Task.sleep(for: .seconds(1))
    }
}

// Two concurrent deposits
async let _ = account.deposit(amount: 100)
async let _ = account.deposit(amount: 100)

// Unexpected: 100 → 200 → 210 → 220
// Expected:   100 → 110 → 210 → 220
```

**Why**: During `logTransaction`, second deposit runs, modifying balance before first completes.

### Avoiding reentrancy bugs

**Complete actor work before suspending**:

```swift
func deposit(amount: Int) async {
    balance += amount
    balance += 10 // Bonus applied first
    print("Final balance: \(balance)")
    
    await logTransaction(amount) // Suspend after state changes
}
```

**Rule**: Don't mutate actor state after suspension points.

> **Course Deep Dive**: This topic is covered in detail in [Lesson 7.3: Understanding Task suspension points](https://www.swiftconcurrencycourse.com?utm_source=github&utm_medium=agent-skill&utm_campaign=lesson-reference)

## Thread Execution Patterns

### Default: Background threads

Tasks run on cooperative thread pool (background threads):

```swift
Task {
    print(Thread.current) // Background thread
}
```

### Main thread execution

Use `@MainActor` for main thread:

```swift
@MainActor
func updateUI() {
    Task {
        print(Thread.current) // Main thread
    }
}
```

### Inheritance example

```swift
@MainActor
func updateUI() {
    print("Main thread: \(Thread.current)")
    
    await backgroundTask() // Switches to background
    
    print("Back on main: \(Thread.current)") // Returns to main
}

func backgroundTask() async {
    print("Background: \(Thread.current)")
}
```

## Swift 6.2 Changes

### Nonisolated async functions (SE-461)

**Old behavior**: Nonisolated async functions always switch to background.

**New behavior**: Inherit caller's isolation by default.

```swift
class NotSendable {
    func performAsync() async {
        print(Thread.current)
    }
}

@MainActor
func caller() async {
    let obj = NotSendable()
    await obj.performAsync()
    // Old: Background thread
    // New: Main thread (inherits @MainActor)
}
```

### Enabling new behavior

In Xcode 16+:

```swift
// Build setting or swift-settings
.enableUpcomingFeature("NonisolatedNonsendingByDefault")
```

### Opting out with @concurrent

Force function to switch away from caller's isolation:

```swift
@concurrent
func performAsync() async {
    print(Thread.current) // Always background
}
```

### nonisolated(nonsending)

Prevent sending non-Sendable values across isolation:

```swift
nonisolated(nonsending) func storeTouch(...) async {
    // Runs on caller's isolation, no value sending
}
```

> **Course Deep Dive**: This topic is covered in detail in [Lesson 7.4: Dispatching to different threads using nonisolated(nonsending) and @concurrent (Updated for Swift 6.2)](https://www.swiftconcurrencycourse.com?utm_source=github&utm_medium=agent-skill&utm_campaign=lesson-reference)

**Use when**: Method doesn't need to switch isolation, avoiding Sendable requirements.

## Default Isolation Domain (SE-466)

### Configuring default isolation

**Build setting** (Xcode 16+):
- Default Actor Isolation: `MainActor` or `None`

**Swift Package**:

```swift
.target(
    name: "MyTarget",
    swiftSettings: [
        .defaultIsolation(MainActor.self)
    ]
)
```

### Why change default?

Most app code runs on main thread. Setting `@MainActor` as default:
- Reduces false warnings
- Avoids "concurrency rabbit hole"
- Makes migration easier

### Inference with @MainActor default

```swift
// With @MainActor as default:

func f() {} // Inferred: @MainActor

class C {
    init() {} // Inferred: @MainActor
    static var value = 10 // Inferred: @MainActor
}

@MyActor
struct S {
    func f() {} // Inferred: @MyActor (explicit override)
}

> **Course Deep Dive**: This topic is covered in detail in [Lesson 7.5: Controlling the default isolation domain (Updated for Swift 6.2)](https://www.swiftconcurrencycourse.com?utm_source=github&utm_medium=agent-skill&utm_campaign=lesson-reference)
```

### Per-module setting

Must opt in for each module/package. Not global across dependencies.

### Backward compatibility

Opt-in only. Default remains `nonisolated` if not specified.

## Debugging Thread Execution

### Print current thread

**⚠️ Important**: `Thread.current` is unavailable in Swift 6 language mode from async contexts. The compiler error states: "Class property 'current' is unavailable from asynchronous contexts; Thread.current cannot be used from async contexts."

**Workaround** (Swift 6+ mode only):

```swift
extension Thread {
    public static var currentThread: Thread {
        Thread.current
    }
}

print("Thread: \(Thread.currentThread)")
```

### Debug navigator

1. Set breakpoint in task
2. Debug → Pause
3. Check Debug Navigator for thread info

### Verify main thread

```swift
assert(Thread.isMainThread)
```

## Common Misconceptions

### ❌ Each Task runs on new thread

**Wrong**. Tasks share limited thread pool, reuse threads.

### ❌ await blocks the thread

**Wrong**. `await` suspends task without blocking thread. Other tasks can use the thread.

### ❌ Task execution order is guaranteed

**Wrong**. Tasks execute based on system scheduling. Use `await` to enforce order.

### ❌ Same task = same thread

**Wrong**. Task can resume on different thread after suspension.

## Why Sendable Matters

Since tasks move between threads unpredictably:

```swift
func example() async {
    print("Thread 1: \(Thread.current)")
    
    await someWork()
    
    print("Thread 2: \(Thread.current)") // Different thread
}
```

Values crossing suspension points may cross threads. **Sendable** ensures safety.

## Best Practices

1. **Stop thinking about threads** - think isolation domains
2. **Trust the system** - Swift optimizes thread usage
3. **Use @MainActor for UI** - clear, explicit main thread execution
4. **Minimize suspension points in actors** - avoid reentrancy bugs
5. **Complete state changes before suspending** - prevent inconsistent state
6. **Use priorities as hints** - not guarantees
7. **Make types Sendable** - safe across thread boundaries
8. **Enable Swift 6.2 features** - easier migration, better defaults
9. **Set default isolation for apps** - reduce false warnings
10. **Don't force thread switching** - let Swift optimize

## Migration Strategy

### For new projects (Xcode 16+)

1. Set default isolation to `@MainActor`
2. Enable `NonisolatedNonsendingByDefault`
3. Use `@concurrent` for explicit background work

### For existing projects

1. Gradually enable Swift 6 language mode
2. Consider default isolation change
3. Use `@concurrent` to maintain old behavior where needed
4. Migrate module by module

## Decision Tree

```
Need to control execution?
├─ UI updates? → @MainActor
├─ Specific state isolation? → Custom actor
├─ Background work? → Regular async (trust Swift)
└─ Need to force background? → @concurrent (Swift 6.2+)

Seeing Sendable warnings?
├─ Can make type Sendable? → Add conformance
├─ Same isolation OK? → nonisolated(nonsending)
└─ Need different isolation? → Make Sendable or refactor
```

## Performance Insights

### Why fewer threads = better performance

- **Less context switching**: CPU spends more time on actual work
- **Better cache utilization**: Threads stay on same cores longer
- **No thread explosion**: Predictable resource usage
- **Forward progress**: Threads never block, always productive

### Cooperative pool advantages

- Matches hardware (one thread per core)
- Prevents oversubscription
- Efficient task scheduling
- Automatic load balancing

## Further Learning

For migration strategies, real-world examples, and advanced threading patterns, see [Swift Concurrency Course](https://www.swiftconcurrencycourse.com).

