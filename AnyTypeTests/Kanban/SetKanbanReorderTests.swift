import Testing
import Foundation
@testable import Anytype

@Suite
struct SetKanbanReorderTests {

    @Test func testPartiallyLoadedColumn_NotFullyLoaded() {
        #expect(SetKanbanReorder.isColumnFullyLoaded(loadedCount: 20, totalCount: 120) == false)
    }

    @Test func testLoadedEqualsTotal_FullyLoaded() {
        #expect(SetKanbanReorder.isColumnFullyLoaded(loadedCount: 20, totalCount: 20) == true)
    }

    @Test func testLoadedExceedsTotal_FullyLoaded() {
        #expect(SetKanbanReorder.isColumnFullyLoaded(loadedCount: 21, totalCount: 20) == true)
    }

    @Test func testUnknownTotal_FailsClosed() {
        #expect(SetKanbanReorder.isColumnFullyLoaded(loadedCount: 20, totalCount: nil) == false)
    }

    @Test func testEmptyColumn_FullyLoaded() {
        #expect(SetKanbanReorder.isColumnFullyLoaded(loadedCount: 0, totalCount: 0) == true)
    }
}
