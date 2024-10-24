import XCTest
@testable import Anytype

final class AnytypeRelativeDateTimeFormatterTests: XCTestCase {

    private let formatter = AnytypeRelativeDateTimeFormatter()

    override func tearDownWithError() throws {
    }

    func testTomorrow() throws {
        let date = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let result = formatter.localizedString(for: date, relativeTo: Date())
        XCTAssertEqual("Tomorrow", result)
    }
    
    func testYesterday() throws {
        let date = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let result = formatter.localizedString(for: date, relativeTo: Date())
        XCTAssertEqual("Yesterday", result)
    }

    func testToday() throws {
        let date = Date()
        let result = formatter.localizedString(for: date, relativeTo: Date())
        XCTAssertEqual("Today", result)
    }
    
    func test7DaysAgo() throws {
        let date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let result = formatter.localizedString(for: date, relativeTo: Date())
        XCTAssertEqual("Previous 7 days", result)
    }
    
    func test14DaysAgo() throws {
        let date = Calendar.current.date(byAdding: .day, value: -14, to: Date())!
        let result = formatter.localizedString(for: date, relativeTo: Date())
        XCTAssertEqual("Previous 14 days", result)
    }
    
    func testMonth() throws {
        let someDate = Date(timeIntervalSince1970: 748439750.379512)
        let someDatePlus31days = Date(timeIntervalSince1970: 745761350.379514)
        let result = formatter.localizedString(for: someDatePlus31days, relativeTo: someDate)
        XCTAssertEqual("August", result)
    }
    
    func testMonthAndYear() throws {
        let date = Date(timeIntervalSince1970: 10)
        let result = formatter.localizedString(for: date, relativeTo: Date())
        XCTAssertEqual("January 1970", result)
    }
    
    func testFutureDate() throws {
        let date = Calendar.current.date(byAdding: .year, value: 6, to: Date())!
        let result = formatter.localizedString(for: date, relativeTo: Date())
        XCTAssertEqual("In six years", result)
    }
}
