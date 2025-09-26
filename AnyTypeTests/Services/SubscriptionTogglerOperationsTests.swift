import Testing
@testable import Anytype

struct SubscriptionTogglerOperationsTests {
    
    @Test(arguments: [
        ("1", ["2", "3", "4", "5", "6"]),
        ("2", ["1", "3", "4", "5", "6"]),
        ("3", ["1", "2", "4", "5", "6"]),
        ("4", ["1", "2", "3", "5", "6"]),
        ("5", ["1", "2", "3", "4", "6"]),
        ("6", ["1", "2", "3", "4", "5"]),
    ])
    func testRemove(_ value: String, _ expected: [String]) async throws {
        var array = ["1", "2", "3", "4", "5", "6"]
        array.applySubscriptionUpdate(.remove(value))
        #expect(array == expected, "value = \(value)")
    }
    
    @Test(arguments: [
        ("7", nil, ["7", "1", "2", "3", "4", "5", "6"]),
        ("7", "1", ["1", "7", "2", "3", "4", "5", "6"]),
        ("7", "2", ["1", "2", "7", "3", "4", "5", "6"]),
        ("7", "3", ["1", "2", "3", "7", "4", "5", "6"]),
        ("7", "4", ["1", "2", "3", "4", "7", "5", "6"]),
        ("7", "5", ["1", "2", "3", "4", "5", "7", "6"]),
        ("7", "6", ["1", "2", "3", "4", "5", "6", "7"]),
    ])
    func testAdd(_ value: String, _ after: String?, _ expected: [String]) async throws {
        var array = ["1", "2", "3", "4", "5", "6"]
        array.applySubscriptionUpdate(.add(value, after: after))
        #expect(array == expected, "value = \(value), after = \(after)")
    }
    
    @Test(arguments: [
        ("1", nil, ["1", "2", "3", "4", "5", "6"]),
        ("1", "2", ["2", "1", "3", "4", "5", "6"]),
        ("1", "3", ["2", "3", "1", "4", "5", "6"]),
        ("1", "6", ["2", "3", "4", "5", "6", "1"]),
        ("6", "5", ["1", "2", "3", "4", "5", "6"]),
        ("6", "4", ["1", "2", "3", "4", "6", "5"]),
        ("6", "1", ["1", "6", "2", "3", "4", "5"]),
        ("6", nil, ["6", "1", "2", "3", "4", "5"]),
    ])
    func testMove(_ from: String, _ after: String?, _ expected: [String]) async throws {
        var array = ["1", "2", "3", "4", "5", "6"]
        array.applySubscriptionUpdate(.move(from: from, after: after))
        #expect(array == expected, "from = \(from), after = \(after)")
    }
}
