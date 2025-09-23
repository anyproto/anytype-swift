import Testing
@testable import Anytype

struct ArrayMoveTests {
    
    @Test(arguments: [
        (0, 2, ["2", "3", "1", "4", "5", "6"]),
        (0, 3, ["2", "3", "4", "1", "5", "6"]),
        (3, 0, ["4", "1", "2", "3", "5", "6"]),
        (5, 4, ["1", "2", "3", "4", "6", "5"]),
    ])
    func testMove(_ from: Int, _ to: Int, _ expected: [String]) async throws {
        var array = ["1", "2", "3", "4", "5", "6"]
        array.moveElement(from: from, to: to)
        #expect(array == expected)
    }
}
