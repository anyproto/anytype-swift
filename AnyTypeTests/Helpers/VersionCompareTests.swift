import XCTest
@testable import Anytype

final class VersionCompareTests: XCTestCase {

    func testAllCases() throws {
        XCTAssertEqual("1.0.0".versionCompare("1.0.0"), .orderedSame)
        XCTAssertEqual("0.0.2".versionCompare("0.0.1"), .orderedDescending)
        XCTAssertEqual("0.1".versionCompare("0.0.1")  , .orderedDescending)
        XCTAssertEqual("0.1.0".versionCompare("0.0.1"), .orderedDescending)
        XCTAssertEqual("0.2".versionCompare("0.1")    , .orderedDescending)
        XCTAssertEqual("1.0.0".versionCompare("1.1")  , .orderedAscending)
        XCTAssertEqual("0.1.0".versionCompare("1.0.0"), .orderedAscending)
        XCTAssertEqual("0.0.1".versionCompare("1.0.0"), .orderedAscending)
        XCTAssertEqual("0.0.1".versionCompare("1")    , .orderedAscending)
        XCTAssertEqual("1.0".versionCompare("2")      , .orderedAscending)
        XCTAssertEqual("1.0.0".versionCompare("1")    , .orderedSame)
        XCTAssertEqual("1.0.0".versionCompare("1.0")  , .orderedSame)
        XCTAssertEqual("1.0.0".versionCompare("1.0.") , .orderedDescending)
    }
}
