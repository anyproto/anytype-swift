import XCTest
@testable import AnyType

fileprivate extension EncodingTests {
    struct Width: Codable, Hashable {
        var width: Int
    }
    struct Size: Codable, Hashable {
        var width: Int
        var height: Int
    }
}

final class EncodingTests: XCTestCase {
    var encoder: URLComponentsEncoder!
    override func setUp() {
        self.encoder = .init()
    }
    
    func testNil() {
        let value = try! encoder.encode(nil as Int?)
        XCTAssertEqual(value, [.init(name: "", value: "nil")])
    }
    
    func testCustomStruct() {
        let structure = Width.init(width: 10)
        let value = try! encoder.encode(structure)
        let result: [URLQueryItem] = [.init(name: "width", value: 10.description)]
        XCTAssertEqual(value, result)
    }
    
    func testComplexStruct() {
        let structure = Size.init(width: 11, height: 12)
        let value = try! encoder.encode(structure)
        let result = [
            URLQueryItem(name: "width", value: 11.description),
            URLQueryItem(name: "height", value: 12.description)
        ]
        XCTAssertEqual(value, result)
    }
}

extension EncodingTests {
    static var allTests = [
        ("testNil", testNil),
        ("testCustomStruct", testCustomStruct),
        ("testComplexStruct", testComplexStruct),
    ]
}
