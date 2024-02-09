import XCTest
@testable import Anytype

final class HomePathTests: XCTestCase {

    var path: HomePath!
    
    override func setUpWithError() throws {
        path = HomePath()
        path.push("1")
        path.push("2")
        path.push("3")
    }

    func testPushOne() {
        path.push("4")
        
        XCTAssertEqual(path.path, ["1", "2", "3", "4"])
        XCTAssertEqual(path.forwardPath, [])
    }

    func testPushMany() {
        path.push("4")
        path.push("5")
        path.push("6")
        
        XCTAssertEqual(path.path, ["1", "2", "3", "4", "5", "6"])
        XCTAssertEqual(path.forwardPath, [])
    }
    
    func testPushSameOne() {
        path.push("4")
        path.pop()
        path.push("4")
        
        XCTAssertEqual(path.path, ["1", "2", "3", "4"])
        XCTAssertEqual(path.forwardPath, [])
    }
    
    func testPushSameMuptiple() {
        path.push("4")
        path.push("5")
        path.push("6")
        
        path.pop()
        path.pop()
        path.pop()
        
        path.push("4")
        path.push("5")
        
        XCTAssertEqual(path.path, ["1", "2", "3", "4", "5"])
        XCTAssertEqual(path.forwardPath, ["6"])
    }
    
    func testPopOne() {
        path.push("4")
        path.push("5")
        path.push("6")

        path.pop()
        
        XCTAssertEqual(path.path, ["1", "2", "3", "4", "5"])
        XCTAssertEqual(path.forwardPath, ["6"])
    }

    func testPopMany() {
        path.push("4")
        path.push("5")
        path.push("6")

        path.pop()
        path.pop()
        path.pop()
        path.pop()
        
        XCTAssertEqual(path.path, ["1", "2"])
        XCTAssertEqual(path.forwardPath, ["6", "5", "4", "3"])
    }
    
    func testPopToRootOne() {
        path.push("4")
        
        path.popToRoot()
        
        XCTAssertEqual(path.path, ["1"])
        XCTAssertEqual(path.forwardPath, ["4", "3", "2"])
    }
    
    func testPopToRootMany() {
        path.push("4")
        
        path.popToRoot()
        path.popToRoot()
        path.popToRoot()
        
        XCTAssertEqual(path.path, ["1"])
        XCTAssertEqual(path.forwardPath, ["4", "3", "2"])
    }
    
    
    func testReplaceLastOne() {
        path.replaceLast("4")
        
        XCTAssertEqual(path.path, ["1", "2", "4"])
        XCTAssertEqual(path.forwardPath, [])
    }
    
    func testReplaceLastMany() {
        path.replaceLast("4")
        path.replaceLast("5")
        path.replaceLast("6")
        
        XCTAssertEqual(path.path, ["1", "2", "6"])
        XCTAssertEqual(path.forwardPath, [])
    }
    
    func testPushFromHistoryEmpty() {
        path.pushFromHistory()
        
        XCTAssertEqual(path.path, ["1", "2", "3"])
        XCTAssertEqual(path.forwardPath, [])
    }
    
    func testPushFromHistoryOneToOne() {
        
        path.pop()
        
        path.pushFromHistory()
        
        XCTAssertEqual(path.path, ["1", "2", "3"])
        XCTAssertEqual(path.forwardPath, [])
    }
    
    func testPushFromHistoryManyToOne() {
        
        path.pop()
        path.pop()
        
        path.pushFromHistory()
        
        XCTAssertEqual(path.path, ["1", "2"])
        XCTAssertEqual(path.forwardPath, ["3"])
    }
    
    func testPushFromHistoryManyToMany() {
        
        path.pop()
        path.pop()
        
        path.pushFromHistory()
        path.pushFromHistory()
        
        XCTAssertEqual(path.path, ["1", "2", "3"])
        XCTAssertEqual(path.forwardPath, [])
    }
    
    func testPushFromHistoryManyToManyHistory() {
        
        path.push("4")
        path.push("5")
        path.push("6")
        
        path.pop()
        path.pop()
        path.pop()
        path.pop()
        
        path.pushFromHistory()
        path.pushFromHistory()
        
        XCTAssertEqual(path.path, ["1", "2", "3", "4"])
        XCTAssertEqual(path.forwardPath, ["6", "5"])
    }
}
