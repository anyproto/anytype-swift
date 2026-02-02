# Task Local Values (WWDC23)

Task-local values attach context to a task hierarchy, automatically propagating through child tasks without explicit parameter passing.

## What are Task Local Values?

A task-local value is data associated with a task hierarchy—like a "global" variable that's scoped to the current task tree.

```swift
enum OrderContext {
    @TaskLocal static var orderID: String?
}

// Access from anywhere in the task tree
func logEvent(_ event: String) {
    if let orderID = OrderContext.orderID {
        print("[\(orderID)] \(event)")
    }
}
```

## Declaration

Declare as static properties with `@TaskLocal`:

```swift
enum RequestContext {
    @TaskLocal static var requestID: String?
    @TaskLocal static var userID: String?
}

// Or on a class/struct
final class Tracing {
    @TaskLocal static var traceID: String?
}
```

**Best practice:** Make task locals optional—unbound values return `nil` by default.

## Binding Values

Task locals can't be assigned directly. Use `$taskLocal.withValue()` to bind for a scope:

```swift
await RequestContext.$requestID.withValue("req-123") {
    // requestID is "req-123" for this entire scope
    await processRequest()
}
// requestID returns to nil (or previous value) here
```

### Binding is scoped

```swift
print(OrderContext.orderID)  // nil

await OrderContext.$orderID.withValue("order-1") {
    print(OrderContext.orderID)  // "order-1"

    await OrderContext.$orderID.withValue("order-2") {
        print(OrderContext.orderID)  // "order-2" (shadowed)
    }

    print(OrderContext.orderID)  // "order-1" (restored)
}

print(OrderContext.orderID)  // nil
```

## Inheritance Rules

### Child tasks inherit task locals

```swift
await RequestContext.$requestID.withValue("req-456") {
    // Child tasks automatically see the value
    async let result1 = fetchData()     // sees "req-456"
    async let result2 = processData()   // sees "req-456"

    await withTaskGroup(of: Void.self) { group in
        group.addTask {
            // Also sees "req-456"
            print(RequestContext.requestID)
        }
    }
}
```

### Detached tasks do NOT inherit

```swift
await RequestContext.$requestID.withValue("req-789") {
    Task.detached {
        // Does NOT see "req-789" - detached tasks don't inherit
        print(RequestContext.requestID)  // nil
    }
}
```

## How It Works (Task Tree)

Task locals use the task tree for lookup:

1. Check current task for bound value
2. If not found, walk up to parent
3. Continue until value found or root reached
4. Return default value if not found

```
makeSoup (orderID = "order-1")
├── chopIngredients (step = "chop")  ← shadows parent's step
│   ├── chopCarrot → sees orderID="order-1", step="chop"
│   └── chopOnion  → sees orderID="order-1", step="chop"
├── marinateMeat   → sees orderID="order-1", step=nil
└── boilBroth      → sees orderID="order-1", step=nil
```

**Performance:** Swift runtime optimizes lookups with direct references, not tree walking.

## Use Cases

### 1. Request tracing / Logging

```swift
enum LogContext {
    @TaskLocal static var requestID: String?
    @TaskLocal static var userID: String?
}

// Metadata provider for swift-log
struct RequestMetadataProvider: MetadataProvider {
    func get() -> Logger.Metadata {
        var metadata: Logger.Metadata = [:]
        if let requestID = LogContext.requestID {
            metadata["request_id"] = "\(requestID)"
        }
        if let userID = LogContext.userID {
            metadata["user_id"] = "\(userID)"
        }
        return metadata
    }
}

// Usage - all logs automatically include context
await LogContext.$requestID.withValue(request.id) {
    await LogContext.$userID.withValue(request.userID) {
        logger.info("Processing request")  // Includes request_id, user_id
        await handleRequest(request)
    }
}
```

### 2. Distributed tracing (server-side)

```swift
import Tracing

// Trace spans automatically propagate via task locals
try await withSpan("handleOrder") { span in
    span.attributes["order.id"] = orderID

    // Child operations get the trace context
    try await withSpan("validatePayment") { _ in
        await paymentService.validate()
    }

    try await withSpan("fulfillOrder") { _ in
        await fulfillmentService.process()
    }
}
```

### 3. Testing / Mocking

```swift
enum TestContext {
    @TaskLocal static var mockDate: Date?
}

// Production code checks for mock
func getCurrentDate() -> Date {
    TestContext.mockDate ?? Date()
}

// Tests can inject mock values
func testExpiredOrder() async {
    let pastDate = Date(timeIntervalSinceNow: -86400)

    await TestContext.$mockDate.withValue(pastDate) {
        let order = await createOrder()
        XCTAssertTrue(order.isExpired)
    }
}
```

### 4. Feature flags / A-B testing

```swift
enum FeatureContext {
    @TaskLocal static var experimentGroup: String?
}

func showRecommendations() async {
    if FeatureContext.experimentGroup == "new-algorithm" {
        await showNewRecommendations()
    } else {
        await showLegacyRecommendations()
    }
}

// Set at request entry point
await FeatureContext.$experimentGroup.withValue(user.experimentGroup) {
    await handleUserSession()
}
```

## Common Patterns

### Combining multiple task locals

```swift
func withRequestContext(
    requestID: String,
    userID: String,
    operation: () async throws -> Void
) async rethrows {
    try await RequestContext.$requestID.withValue(requestID) {
        try await RequestContext.$userID.withValue(userID) {
            try await operation()
        }
    }
}

// Usage
await withRequestContext(requestID: "123", userID: "user-1") {
    await processRequest()
}
```

### Shadowing for sub-operations

```swift
enum ProcessingContext {
    @TaskLocal static var step: String?
}

func makeSoup() async {
    await ProcessingContext.$step.withValue("soup") {
        logger.info("Starting")  // step = "soup"

        await ProcessingContext.$step.withValue("prep") {
            await chopIngredients()  // step = "prep"
        }

        await ProcessingContext.$step.withValue("cook") {
            await cookSoup()  // step = "cook"
        }

        logger.info("Done")  // step = "soup" (restored)
    }
}
```

## Best Practices

1. **Make task locals optional** - Unbound values should have sensible defaults
2. **Use for cross-cutting concerns** - Logging, tracing, feature flags
3. **Don't overuse** - Explicit parameters are clearer for core business logic
4. **Remember detached tasks don't inherit** - Use regular `Task` if you need inheritance
5. **Keep values immutable** - Task locals should be read-only context, not shared mutable state

## When NOT to Use Task Locals

- **Core business data** - Pass explicitly as parameters
- **Mutable shared state** - Use actors instead
- **Configuration that rarely changes** - Use dependency injection
- **Data that needs to cross detached task boundaries** - Pass explicitly

## Further Reading

- [WWDC23: Beyond the basics of structured concurrency](https://developer.apple.com/videos/play/wwdc2023/10170/)
- [Swift Distributed Tracing](https://github.com/apple/swift-distributed-tracing)
- [Swift Log](https://github.com/apple/swift-log)
