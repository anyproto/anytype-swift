import XCTest
@testable import Anytype


class EditorSetMarkdownHelpertests: XCTestCase {
    
    var helper: EditorSetPaginationHelper!

    override func setUpWithError() throws {
        helper = EditorSetPaginationHelper()
    }

    override func tearDownWithError() throws {
        helper = nil
    }

    // MARK: - updatePageCount
    func test_updatePageCount_smaller_amount() throws {
        let data = EditorSetPaginationData(selectedPage: 1, visiblePages: [1, 2, 3, 4, 5], pageCount: 5)
        
        let result = helper.updatePageCount(3, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 1)
        XCTAssertEqual(result!.data.visiblePages, [1, 2, 3])
        XCTAssertEqual(result!.data.pageCount, 3)
    }
    
    func test_updatePageCount_same_amount() throws {
        let data = EditorSetPaginationData(selectedPage: 1, visiblePages: [1, 2, 3, 4, 5], pageCount: 5)
        
        let result = helper.updatePageCount(5, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 1)
        XCTAssertEqual(result!.data.visiblePages, [1, 2, 3, 4, 5])
        XCTAssertEqual(result!.data.pageCount, 5)
    }
    
    func test_updatePageCount_bigger_amount() throws {
        let data = EditorSetPaginationData(selectedPage: 1, visiblePages: [1, 2, 3, 4, 5], pageCount: 5)
        
        let result = helper.updatePageCount(50, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 1)
        XCTAssertEqual(result!.data.visiblePages, [1, 2, 3, 4, 5])
        XCTAssertEqual(result!.data.pageCount, 50)
    }
    
    func test_updatePageCount_add_visible_pages_v1() throws {
        let data = EditorSetPaginationData(selectedPage: 1, visiblePages: [1, 2, 3], pageCount: 3)
        
        let result = helper.updatePageCount(4, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 1)
        XCTAssertEqual(result!.data.visiblePages, [1, 2, 3, 4])
        XCTAssertEqual(result!.data.pageCount, 4)
    }
    
    func test_updatePageCount_add_visible_pages_v2() throws {
        let data = EditorSetPaginationData(selectedPage: 1, visiblePages: [1, 2, 3], pageCount: 3)
        
        let result = helper.updatePageCount(5, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 1)
        XCTAssertEqual(result!.data.visiblePages, [1, 2, 3, 4, 5])
        XCTAssertEqual(result!.data.pageCount, 5)
    }
    
    func test_updatePageCount_add_visible_pages_v3() throws {
        let data = EditorSetPaginationData(selectedPage: 1, visiblePages: [1, 2, 3], pageCount: 3)
        
        let result = helper.updatePageCount(50, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 1)
        XCTAssertEqual(result!.data.visiblePages, [1, 2, 3, 4, 5])
        XCTAssertEqual(result!.data.pageCount, 50)
    }
    
    func test_updatePageCount_remove_visible_pages() throws {
        let data = EditorSetPaginationData(selectedPage: 1, visiblePages: [1, 2, 3], pageCount: 3)
        
        let result = helper.updatePageCount(2, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 1)
        XCTAssertEqual(result!.data.visiblePages, [1, 2])
        XCTAssertEqual(result!.data.pageCount, 2)
    }
    
    func test_updatePageCount_remove_visible_pages_and_update_selected_page() throws {
        let data = EditorSetPaginationData(selectedPage: 3, visiblePages: [1, 2, 3], pageCount: 3)
        
        let result = helper.updatePageCount(2, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, true)
        XCTAssertEqual(result!.data.selectedPage, 2)
        XCTAssertEqual(result!.data.visiblePages, [1, 2])
        XCTAssertEqual(result!.data.pageCount, 2)
    }
    
    func test_updatePageCount_remove_visible_pages_and_update_entire_row() throws {
        let data = EditorSetPaginationData(selectedPage: 3, visiblePages: [6, 7, 8], pageCount: 8)
        
        let result = helper.updatePageCount(3, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 3)
        XCTAssertEqual(result!.data.visiblePages, [1, 2, 3])
        XCTAssertEqual(result!.data.pageCount, 3)
    }
    
    func test_updatePageCount_remove_visible_pages_and_update_entire_row_v2() throws {
        let data = EditorSetPaginationData(selectedPage: 3, visiblePages: [6, 7, 8], pageCount: 8)
        
        let result = helper.updatePageCount(5, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 3)
        XCTAssertEqual(result!.data.visiblePages, [1, 2, 3, 4, 5])
        XCTAssertEqual(result!.data.pageCount, 5)
    }
    
    func test_updatePageCount_remove_visible_pages_and_update_entire_row_and_selected_page() throws {
        let data = EditorSetPaginationData(selectedPage: 6, visiblePages: [6, 7, 8], pageCount: 8)
        
        let result = helper.updatePageCount(5, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, true)
        XCTAssertEqual(result!.data.selectedPage, 5)
        XCTAssertEqual(result!.data.visiblePages, [1, 2, 3, 4, 5])
        XCTAssertEqual(result!.data.pageCount, 5)
    }
    
    func test_updatePageCount_for_showMore_logic_when_ignorePageLimit() throws {
        let data = EditorSetPaginationData(selectedPage: 3, visiblePages: [1, 2, 3], pageCount: 3)
        
        let result = helper.updatePageCount(2, data: data, ignorePageLimit: true)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 3)
        XCTAssertEqual(result!.data.pageCount, 2)
    }
    
    func test_updatePageCount_zero() throws {
        let data = EditorSetPaginationData(selectedPage: 6, visiblePages: [6, 7, 8], pageCount: 8)
        
        let result = helper.updatePageCount(0, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 0)
        XCTAssertEqual(result!.data.visiblePages, [])
        XCTAssertEqual(result!.data.pageCount, 0)
    }
    
    func test_updatePageCount_empty_initial_state_one_page() throws {
        let data = EditorSetPaginationData(selectedPage: 0, visiblePages: [], pageCount: 0)
        
        let result = helper.updatePageCount(1, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, true)
        XCTAssertEqual(result!.data.selectedPage, 1)
        XCTAssertEqual(result!.data.visiblePages, [1])
        XCTAssertEqual(result!.data.pageCount, 1)
    }
    
    func test_updatePageCount_empty_initial_state_ten_pages() throws {
        let data = EditorSetPaginationData(selectedPage: 0, visiblePages: [], pageCount: 0)
        
        let result = helper.updatePageCount(10, data: data, ignorePageLimit: false)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, true)
        XCTAssertEqual(result!.data.selectedPage, 1)
        XCTAssertEqual(result!.data.visiblePages, [1, 2, 3, 4, 5])
        XCTAssertEqual(result!.data.pageCount, 10)
    }
    
    
    // MARK: - changePage
    func test_changePage() throws {
        let data = EditorSetPaginationData(selectedPage: 3, visiblePages: [6, 7, 8], pageCount: 8)
        
        let result = helper.changePage(7, data: data)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, true)
        XCTAssertEqual(result!.data.selectedPage, 7)
        XCTAssertEqual(result!.data.visiblePages, [6, 7, 8])
        XCTAssertEqual(result!.data.pageCount, 8)
    }
    
    func test_changePage_wrong_number() throws {
        let data = EditorSetPaginationData(selectedPage: 3, visiblePages: [6, 7, 8], pageCount: 8)
        
        let result = helper.changePage(10, data: data)
        
        XCTAssertNil(result)
    }
    
    // MARK: - goForwardRow
    func test_goForwardRow() throws {
        let data = EditorSetPaginationData(selectedPage: 3, visiblePages: [1, 2, 3, 4, 5], pageCount: 8)
        
        let result = helper.goForwardRow(data: data)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 3)
        XCTAssertEqual(result!.data.visiblePages, [6, 7, 8])
        XCTAssertEqual(result!.data.pageCount, 8)
    }
    
    func test_goForwardRow_last_row() throws {
        let data = EditorSetPaginationData(selectedPage: 3, visiblePages: [6, 7, 8], pageCount: 8)
        
        let result = helper.goForwardRow(data: data)
        
        XCTAssertNil(result)
    }
    
    // MARK: - goBackwardRow
    func test_goBackwardRow() throws {
        let data = EditorSetPaginationData(selectedPage: 3, visiblePages: [6, 7, 8], pageCount: 8)
        
        let result = helper.goBackwardRow(data: data)
        
        XCTAssertEqual(result!.shoudUpdateSubscription, false)
        XCTAssertEqual(result!.data.selectedPage, 3)
        XCTAssertEqual(result!.data.visiblePages, [1, 2, 3, 4, 5])
        XCTAssertEqual(result!.data.pageCount, 8)
    }
    
    func test_goBackwardRow_first_row() throws {
        let data = EditorSetPaginationData(selectedPage: 3, visiblePages: [1, 2, 3, 4, 5], pageCount: 8)
        
        let result = helper.goBackwardRow(data: data)
        
        XCTAssertNil(result)
    }
    
    
}
