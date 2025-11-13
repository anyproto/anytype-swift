# Tests Developer Skill

Smart router to testing patterns and practices. Writing unit tests, creating mocks, test organization.

## When to Use This Skill

This skill activates when working with:
- Writing unit tests
- Creating test mocks
- Testing edge cases
- Test-driven development (TDD)
- Test refactoring and updates
- Swift Testing framework usage
- XCTest framework usage

## Quick Reference

### Critical Rules
- ✅ **Use Swift Testing framework** (`import Testing`, `@Test`, `@Suite`) for NEW tests
- ✅ **Keep existing XCTest tests** as-is (don't migrate unless necessary)
- ✅ **Test edge cases**: nil values, empty collections, boundary conditions
- ✅ **Create mock helpers** in test file extensions when needed
- ✅ **Update tests when refactoring** - always search and update references
- ❌ **Never skip tests** for data transformation or business logic
- ❌ **Never use force unwrapping** in tests - use proper assertions

### Test File Naming
```
ProductionCode:  SetContentViewDataBuilder.swift
Test File:       SetContentViewDataBuilderTests.swift
Location:        AnyTypeTests/[Category]/[TestFile].swift
```

### Swift Testing Framework (Preferred for New Tests)

**Basic Structure:**
```swift
import Testing
import Foundation
@testable import Anytype
import Services

@Suite
struct MyFeatureTests {

    private let sut: MyFeature  // System Under Test

    init() {
        self.sut = MyFeature()
    }

    @Test func testSpecificBehavior() {
        // Arrange
        let input = "test"

        // Act
        let result = sut.process(input)

        // Assert
        #expect(result == "expected")
    }

    @Test func testEdgeCase_EmptyInput_ReturnsNil() {
        let result = sut.process("")
        #expect(result == nil)
    }
}
```

**Suite Options:**
```swift
@Suite                      // Parallel execution (default)
@Suite(.serialized)        // Sequential execution (for shared state)
```

**Assertions:**
```swift
#expect(value == expected)           // Equality
#expect(value != unexpected)         // Inequality
#expect(result != nil)               // Not nil
#expect(array.isEmpty)               // Boolean conditions
#expect(throws: SomeError.self) {    // Error throwing
    try throwingFunction()
}
```

### XCTest Framework (Legacy Tests)

**Basic Structure:**
```swift
import XCTest
@testable import Anytype

final class MyFeatureTests: XCTestCase {

    var sut: MyFeature!

    override func setUpWithError() throws {
        sut = MyFeature()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testSpecificBehavior() {
        // Arrange
        let input = "test"

        // Act
        let result = sut.process(input)

        // Assert
        XCTAssertEqual(result, "expected")
    }
}
```

**Common Assertions:**
```swift
XCTAssertEqual(actual, expected)
XCTAssertNotEqual(actual, unexpected)
XCTAssertNil(value)
XCTAssertNotNil(value)
XCTAssertTrue(condition)
XCTAssertFalse(condition)
XCTAssertThrowsError(try expression)
```

## Test Organization Patterns

### 1. Edge Case Testing (Critical)

Always test these scenarios:
```swift
@Test func testEmptyInput() {
    let result = sut.process([])
    #expect(result.isEmpty)
}

@Test func testNilInput() {
    let result = sut.process(nil)
    #expect(result == nil)
}

@Test func testSingleItem() {
    let result = sut.process([item])
    #expect(result.count == 1)
}

@Test func testBoundaryCondition() {
    let items = (0..<100).map { Item(id: "\($0)") }
    let result = sut.process(items)
    #expect(result.count <= 100)
}

@Test func testTruncation_LimitsToMax() {
    let attachments = (0..<5).map { ObjectDetails.mock(id: "item\($0)") }
    let result = sut.truncate(attachments, limit: 3)
    #expect(result.count == 3)
    #expect(result[0].id == "item0")
    #expect(result[2].id == "item2")
}
```

### 2. Mock Helpers (In Test File)

**Location:** Create as extensions in the same test file
```swift
// At bottom of test file
extension ObjectDetails {
    static func mock(id: String) -> ObjectDetails {
        ObjectDetails(id: id, values: [:])
    }
}

extension Participant {
    static func mock(
        id: String,
        globalName: String = "",
        icon: ObjectIcon? = nil
    ) -> Participant {
        Participant(
            id: id,
            localName: "",
            globalName: globalName,
            icon: icon,
            status: .active,
            permission: .reader,
            identity: "",
            identityProfileLink: "",
            spaceId: "",
            type: ""
        )
    }
}
```

### 3. Dependency Injection in Tests

**Using Factory Pattern:**
```swift
@Suite(.serialized)  // Required for DI setup
struct MyFeatureTests {

    private let mockService: MyServiceMock

    init() {
        let mockService = MyServiceMock()
        Container.shared.myService.register { mockService }
        self.mockService = mockService
    }

    @Test func testWithMockedDependency() {
        mockService.expectedResult = "test"
        let sut = MyFeature()
        let result = sut.doWork()
        #expect(result == "test")
    }
}
```

### 4. Testing Protocols (Make Methods Internal)

**Problem:** Private methods can't be tested
**Solution:** Use `internal` access and test via protocol
```swift
// Production code - SetContentViewDataBuilder.swift
final class SetContentViewDataBuilder: SetContentViewDataBuilderProtocol {

    // ✅ Internal for testing (not private)
    func buildChatPreview(
        objectId: String,
        spaceView: SpaceView?,
        chatPreviewsDict: [String: ChatMessagePreview]
    ) -> MessagePreviewModel? {
        // Implementation
    }
}

// Test code
@Test func testBuildChatPreview_EmptyDict_ReturnsNil() {
    let result = builder.buildChatPreview(
        objectId: "test",
        spaceView: nil,
        chatPreviewsDict: [:]
    )
    #expect(result == nil)
}
```

### 5. Dictionary Conversion Testing

**Performance validation:**
```swift
@Test func testDictionaryConversion_EmptyArray() {
    let items: [Item] = []
    let dict = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
    #expect(dict.isEmpty)
}

@Test func testDictionaryConversion_MultipleItems() {
    let items = (0..<10).map { Item(id: "item\($0)") }
    let dict = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })

    #expect(dict.count == 10)
    for i in 0..<10 {
        #expect(dict["item\(i)"] != nil)
    }
}

@Test func testDictionaryLookup_O1Performance() {
    let items = (0..<100).map { Item(id: "item\($0)") }
    let dict = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })

    let result = dict["item50"]
    #expect(result != nil)
    #expect(result?.id == "item50")
}
```

### 6. Testing with Dates

```swift
@Test func testDateFormatting() {
    let date = Date(timeIntervalSince1970: 1700000000)
    let result = formatter.format(date)
    #expect(result.isEmpty == false)
}

@Test func testDateComparison() {
    let now = Date()
    let future = now.addingTimeInterval(3600)
    #expect(future > now)
}
```

### 7. Testing Protobuf Models

**ChatState example:**
```swift
@Test func testChatStateCounters() {
    var chatState = ChatState()

    var messagesState = ChatState.UnreadState()
    messagesState.counter = 5
    chatState.messages = messagesState

    var mentionsState = ChatState.UnreadState()
    mentionsState.counter = 2
    chatState.mentions = mentionsState

    #expect(chatState.messages.counter == 5)
    #expect(chatState.mentions.counter == 2)
}
```

## Mock Services Pattern

### Preview Mocks (for SwiftUI Previews)

**Location:** `Anytype/Sources/PreviewMocks/`

**Usage:**
```swift
import SwiftUI

#Preview {
    MockView {
        // Configure mock state
        SpaceViewsStorageMock.shared.workspaces = [...]
    } content: {
        MyView()
    }
}
```

### Test Mocks (for Unit Tests)

**Location:** `AnyTypeTests/Mocks/` or in test file

**Pattern:**
```swift
@testable import Anytype

final class MyServiceMock: MyServiceProtocol {
    var callCount = 0
    var capturedInput: String?
    var stubbedResult: Result?

    func process(_ input: String) -> Result {
        callCount += 1
        capturedInput = input
        return stubbedResult ?? .default
    }
}
```

## Testing Checklist

When writing tests, ensure:
- [ ] Test happy path (valid input, expected output)
- [ ] Test edge cases (nil, empty, boundary conditions)
- [ ] Test error conditions (invalid input, throwing functions)
- [ ] Test data transformations (truncation, filtering, mapping)
- [ ] Test performance assumptions (O(1) lookups, O(n) operations)
- [ ] Create mock helpers for complex types
- [ ] Use descriptive test names: `testFeature_Condition_ExpectedBehavior`
- [ ] Follow AAA pattern: Arrange, Act, Assert
- [ ] No force unwrapping (`!`) - use proper assertions
- [ ] Import only necessary modules (`@testable import Anytype`)

## When Refactoring Production Code

**CRITICAL:** Always update tests when refactoring:

1. **Search for test references:**
```bash
rg "OldClassName" AnyTypeTests/ --type swift
rg "oldPropertyName" AnyTypeTests/ --type swift
```

2. **Update test mocks:**
   - Check `AnyTypeTests/Mocks/`
   - Check `Anytype/Sources/PreviewMocks/`
   - Update DI registrations in `MockView.swift`

3. **Update mock extensions:**
   - Search for `.mock(` in test files
   - Update parameters if initializer changed

4. **Run tests before committing:**
   - User will verify in Xcode (faster with caches)
   - Report all test file changes to user

## Common Test Patterns in Codebase

### Pattern 1: Builder Testing
```swift
@Test func testBuilderCreatesCorrectModel() {
    let input = [...setup...]
    let result = builder.build(input)

    #expect(result.property1 == expected1)
    #expect(result.property2 == expected2)
    #expect(result.collection.count == 3)
}
```

### Pattern 2: Storage/Repository Testing
```swift
@Suite(.serialized)
struct StorageTests {
    init() {
        // Setup mock dependencies
    }

    @Test func testSaveAndRetrieve() {
        storage.save(item)
        let retrieved = storage.get(item.id)
        #expect(retrieved?.id == item.id)
    }
}
```

### Pattern 3: Parser/Formatter Testing
```swift
@Test func testParseValidInput() {
    let result = parser.parse("valid input")
    #expect(result != nil)
}

@Test func testParseInvalidInput_ReturnsNil() {
    let result = parser.parse("")
    #expect(result == nil)
}
```

### Pattern 4: Counter/State Testing
```swift
@Test func testCountersPropagation() {
    var model = Model()
    model.state = createState(messages: 5, mentions: 2)

    #expect(model.unreadCounter == 5)
    #expect(model.mentionCounter == 2)
}
```

## Test File Examples

### Example 1: SetContentViewDataBuilderTests.swift
**Full working example:** `AnyTypeTests/Services/SetContentViewDataBuilderTests.swift`
- Tests builder methods
- Creates mock helpers
- Tests edge cases (nil, empty, truncation)
- Tests counter propagation
- Tests dictionary conversion performance

### Example 2: ChatMessageLimitsTests.swift
**Full working example:** `AnyTypeTests/Services/ChatMessageLimitsTests.swift`
- Uses @Suite(.serialized) for DI setup
- Mocks date provider via Factory DI
- Tests rate limiting logic
- Tests time-based conditions

## Related Documentation

- **CLAUDE.md**: Project guidelines, no comments rule, testing requirements
- **IOS_DEVELOPMENT_GUIDE.md**: Swift patterns, MVVM architecture
- **.claude/CODE_REVIEW_GUIDE.md**: Review standards including test updates

---

**Navigation**: This is a smart router. For comprehensive testing guidelines and architecture patterns, refer to `IOS_DEVELOPMENT_GUIDE.md`.

**Quick help**: Just ask "How do I test X?" or "Create tests for Y feature"
