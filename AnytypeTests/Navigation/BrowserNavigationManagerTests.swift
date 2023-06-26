import XCTest
@testable import Anytype

class BrowserNavigationManagerTests: XCTestCase {
    
    var manager: BrowserNavigationManager!

    override func setUpWithError() throws {
        manager = BrowserNavigationManager()
    }
    
    func test_default_state() throws {
        XCTAssertEqual(manager.openedPages.count, 0)
        XCTAssertEqual(manager.closedPages.count, 0)
    }

    func test_navigation_controller_duplicate_call_for_first_page_is_ignored() throws {
        let page = createPage()
        push(page: page)
        childrenCount = 0
        push(page: page)
        
        XCTAssertEqual(manager.openedPages.count, 1)
        XCTAssertEqual(manager.closedPages.count, 0)
    }
    
    func test_moveForwardOnce() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        pop(to: page1)
        
        let moved = manager.moveForwardOnce()
        push(page: page2)
        
        XCTAssertEqual(moved, true)
        XCTAssertEqual(manager.openedPages.count, 2)
        XCTAssertEqual(manager.closedPages.count, 0)
    }
    
    func test_moveForward_one_level() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        pop(to: page1)
        
        try! manager.moveForward(page: page2)
        push(page: page2)
        
        XCTAssertEqual(manager.openedPages.count, 2)
        XCTAssertEqual(manager.closedPages.count, 0)
    }
    
    func test_move_forward_three_levels() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        let page3 = createPage()
        push(page: page3)
        let page4 = createPage()
        push(page: page4)
        
        pop(to: page3)
        pop(to: page2)
        pop(to: page1)
        
        try! manager.moveForward(page: page4)
        push(page: page4)
        
        XCTAssertEqual(manager.openedPages.count, 2)
        XCTAssertEqual(manager.closedPages.count, 0)
    }
    
    func test_move_forward_once_with_closed_pages() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        let page3 = createPage()
        push(page: page3)
        let page4 = createPage()
        push(page: page4)
        
        pop(to: page3)
        pop(to: page2)
        pop(to: page1)
        
        _ = manager.moveForwardOnce()
        push(page: page2)
        
        XCTAssertEqual(manager.openedPages.count, 2)
        XCTAssertEqual(manager.closedPages.count, 2)
    }
    
    func test_move_forward_with_closed_pages() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        let page3 = createPage()
        push(page: page3)
        let page4 = createPage()
        push(page: page4)
        
        pop(to: page3)
        pop(to: page2)
        pop(to: page1)
        
        try! manager.moveForward(page: page2)
        push(page: page2)
        
        XCTAssertEqual(manager.openedPages.count, 2)
        XCTAssertEqual(manager.closedPages.count, 2)
    }
    
    func test_move_forward_after_pop() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        let page3 = createPage()
        push(page: page3)
        pop(to: page2)
        
        push(page: page3)
        
        XCTAssertEqual(manager.openedPages.count, 3)
        XCTAssertEqual(manager.closedPages.count, 0)
    }
    
    func test_pop() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        
        pop(to: page1)
        
        XCTAssertEqual(manager.openedPages.count, 1)
        XCTAssertEqual(manager.closedPages.count, 1)
    }
    
    func test_pop_three_levels() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        let page3 = createPage()
        push(page: page3)
        let page4 = createPage()
        push(page: page4)
        
        pop(to: page3)
        pop(to: page2)
        pop(to: page1)
        
        XCTAssertEqual(manager.openedPages.count, 1)
        XCTAssertEqual(manager.closedPages.count, 3)
    }
    
    func test_pop_after_forward() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        pop(to: page1)
        
        try! manager.moveForward(page: page2)
        push(page: page2)
        
        pop(to: page1)
        
        XCTAssertEqual(manager.openedPages.count, 1)
        XCTAssertEqual(manager.closedPages.count, 1)
    }
    
    func test_move_back() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        let page3 = createPage()
        push(page: page3)
        let page4 = createPage()
        push(page: page4)
        
        try! manager.moveBack(page: page2)
        pop(to: page1)
        
        XCTAssertEqual(manager.openedPages.count, 2)
        XCTAssertEqual(manager.closedPages.count, 2)
    }
    
    func test_move_forward_after_move_back() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        let page3 = createPage()
        push(page: page3)
        
        try! manager.moveBack(page: page2)
        pop(to: page2)
        
        push(page: page3)
        
        XCTAssertEqual(manager.openedPages.count, 3)
        XCTAssertEqual(manager.closedPages.count, 0)
    }
    
    func test_pop_after_return_from_move_back() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        
        try! manager.moveBack(page: page1)
        pop(to: page1)
        
        push(page: page2)
        
        // when
        pop(to: page1)
        
        XCTAssertEqual(manager.openedPages.count, 1)
        XCTAssertEqual(manager.closedPages.count, 1)
    }
    
    func test_pop_after_return_from_pop() throws {
        let page1 = createPage()
        push(page: page1)
        let page2 = createPage()
        push(page: page2)
        pop(to: page1)
        push(page: page2)
        
        // when
        pop(to: page1)
        
        XCTAssertEqual(manager.openedPages.count, 1)
        XCTAssertEqual(manager.closedPages.count, 1)
    }
    
    private var childrenCount = 0
    
    private func push(page: BrowserPage) {
        childrenCount += 1
        try! manager.didShow(page: page, childernCount: childrenCount)
    }
    
    private func pop(to page: BrowserPage) {
        childrenCount -= 1
        try! manager.didShow(page: page, childernCount: childrenCount)
    }
    
    private var controllersStorage = [UIViewController]()
    private func createPage() -> BrowserPage {
        let controller = UIViewController()
        controllersStorage.append(controller)
        let pageData: EditorScreenData = .page(EditorPageObject(objectId: UUID().uuidString, isSupportedForEdit: true, isOpenedForPreview: false))
        return BrowserPage(pageData: pageData, title: nil, subtitle: nil, controller: controller)
    }
}
