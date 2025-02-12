import Testing
@testable import Anytype

struct MessageAttachmentsGridLayoutBuilderTests {

    @Test(arguments: [
        [], // 0
        [1], // 1
        [2], // 2
        [3], // 3
        [2, 2], // 4
        [2, 3], // 5
        [3, 3], // 6
        [2, 2, 3], // 7
        [2, 3, 3], // 8
        [3, 3, 3], // 9
        [2, 2, 3, 3] // 10
    ])
    func testVariants(expectedResult: [Int]) async throws {
        let items = expectedResult.reduce(0, { $0 + $1})
        let result = MessageAttachmentsGridLayoutBuilder.makeGridRows(countItems: items)
        #expect(result == expectedResult)
    }
}
