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
    }

    func testPushMany() {
        path.push("4")
        path.push("5")
        path.push("6")
        
        XCTAssertEqual(path.path, ["1", "2", "3", "4", "5", "6"])
    }
    
    func testPushSameOne() {
        path.push("4")
        path.pop()
        path.push("4")
        
        XCTAssertEqual(path.path, ["1", "2", "3", "4"])
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
    }
    
    func testPopOne() {
        path.push("4")
        path.push("5")
        path.push("6")

        path.pop()
        
        XCTAssertEqual(path.path, ["1", "2", "3", "4", "5"])
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
    }
    
    func testPopToRootOne() {
        path.push("4")
        
        path.popToRoot()
        
        XCTAssertEqual(path.path, ["1"])
    }
    
    func testPopToRootMany() {
        path.push("4")
        
        path.popToRoot()
        path.popToRoot()
        path.popToRoot()
        
        XCTAssertEqual(path.path, ["1"])
    }
    
    
    func testReplaceLastOne() {
        path.replaceLast("4")
        
        XCTAssertEqual(path.path, ["1", "2", "4"])
    }
    
    func testReplaceLastMany() {
        path.replaceLast("4")
        path.replaceLast("5")
        path.replaceLast("6")
        
        XCTAssertEqual(path.path, ["1", "2", "6"])
    }
}
