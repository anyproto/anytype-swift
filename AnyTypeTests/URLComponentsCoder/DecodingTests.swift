import XCTest
@testable import AnyType

fileprivate extension DecodingTests {
    struct Width: Codable, Hashable {
        var width: Int
    }
    struct Size: Codable, Hashable {
        var width: Int
        var height: Int
    }
}

final class DecodingTests: XCTestCase {
    var decoder: URLComponentsDecoder!
    override func setUp() {
        self.decoder = .init()
    }
    
    func testCustomStruct() {
        let structure = Width.init(width: 10)
        let encoded: [URLQueryItem] = [.init(name: "width", value: structure.width.description)]
        
        let value = try! decoder.decode(Width.self, from: encoded)
        
        XCTAssertEqual(value, structure)
    }
    
    func testComplexStruct() {
        let structure = Size.init(width: 11, height: 12)
        let encoded: [URLQueryItem] = [.init(name: "width", value: structure.width.description), .init(name: "height", value: structure.height.description)]
        
        let value = try! decoder.decode(Size.self, from: encoded)
        
        XCTAssertEqual(value, structure)
    }
}

extension DecodingTests {
    static var allTests = [
        ("testCustomStruct", testCustomStruct),
        ("testComplexStruct", testComplexStruct),
    ]
}
