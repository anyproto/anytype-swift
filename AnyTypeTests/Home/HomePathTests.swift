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

    func testCurrentHomeReturnsIndexOne() {
        var twoElementPath = HomePath()
        twoElementPath.push("root")
        twoElementPath.push("home")

        XCTAssertEqual(twoElementPath.currentHome, AnyHashable("home"))
        XCTAssertEqual(twoElementPath.currentHome, twoElementPath.path[1])
    }

    func testCurrentHomeNilWhenPathEmpty() {
        let emptyPath = HomePath()

        XCTAssertNil(emptyPath.currentHome)
    }

    func testCurrentHomeNilWhenOnlyRoot() {
        var rootOnly = HomePath()
        rootOnly.push("root")

        XCTAssertNil(rootOnly.currentHome)
    }

    func testReplaceHomeOnValidPath() {
        var twoElementPath = HomePath()
        twoElementPath.push("root")
        twoElementPath.push("oldHome")

        twoElementPath.replaceHome("newHome")

        XCTAssertEqual(twoElementPath.path, ["root", "newHome"])

        var threeElementPath = HomePath()
        threeElementPath.push("root")
        threeElementPath.push("oldHome")
        threeElementPath.push("pushed")

        threeElementPath.replaceHome("newHome")

        XCTAssertEqual(threeElementPath.path, ["root", "newHome", "pushed"])
    }

    func testReplaceHomeSameValueNoOp() {
        var samePath = HomePath()
        samePath.push("root")
        samePath.push("home")

        samePath.replaceHome("home")

        XCTAssertEqual(samePath.path, ["root", "home"])
    }

    func testReplaceHomeOnRootlessPath() {
        var emptyPath = HomePath()
        emptyPath.replaceHome("home")
        XCTAssertEqual(emptyPath.path, [])

        var rootOnlyPath = HomePath()
        rootOnlyPath.push("root")
        rootOnlyPath.replaceHome("home")
        XCTAssertEqual(rootOnlyPath.path, ["root"])
    }
}
