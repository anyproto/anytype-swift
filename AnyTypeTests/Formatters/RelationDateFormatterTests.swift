import XCTest
@testable import Anytype

final class RelationDateFormatterTests: XCTestCase {

    private let formatter = DateFormatter.relationDateFormatter

    override func tearDownWithError() throws {
    }

    func testTomorrow() throws {
        let date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let result = formatter.string(from: date)
        XCTAssertEqual("Tomorrow", result)
    }
    
    func testYesterday() throws {
        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let result = formatter.string(from: date)
        XCTAssertEqual("Yesterday", result)
    }

    func testToday() throws {
        let date = Date()
        let result = formatter.string(from: date)
        XCTAssertEqual("Today", result)
    }
    
    func testOldDate() throws {
        let date = Date(timeIntervalSince1970: 1597223765)
        let result = formatter.string(from: date)
        XCTAssertEqual("12 Aug 2020", result)
    }
    
    func testFutureDate() throws {
        let date = Date(timeIntervalSince1970: 1912756565)
        let result = formatter.string(from: date)
        XCTAssertEqual("12 Aug 2030", result)
    }
}
