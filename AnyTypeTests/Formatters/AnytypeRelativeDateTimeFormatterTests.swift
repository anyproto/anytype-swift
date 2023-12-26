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
    
    func test30DaysAgo() throws {
        let date = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let result = formatter.localizedString(for: date, relativeTo: Date())
        XCTAssertEqual("Previous 30 days", result)
    }
    
    func testOldDate() throws {
        let date = Calendar.current.date(byAdding: .day, value: -31, to: Date())!
        let result = formatter.localizedString(for: date, relativeTo: Date())
        XCTAssertEqual("Older", result)
    }
    
    func testFutureDate() throws {
        let date = Calendar.current.date(byAdding: .year, value: 6, to: Date())!
        let result = formatter.localizedString(for: date, relativeTo: Date())
        XCTAssertEqual("In six years", result)
    }
}
