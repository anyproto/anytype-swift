import XCTest
@testable import DeepLinks
import AnytypeCore

final class DeepLinkParserTests: XCTestCase {

    var parser: DeepLinkParser!
    
    override func setUpWithError() throws {
        parser = DeepLinkParser()
    }

    override func tearDownWithError() throws {
    }

    func testNormal() throws {
        let url = URL(string: "anytype://create-object")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .createDefaultObject)
    }
    
    func testNarmalWithSlash() throws {
        let url = URL(string: "anytype://create-object/")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .createDefaultObject)
    }
    
    func testProdOnProd() throws {
        CoreEnvironment.isDebug = false
        let url = URL(string: "prod-anytype://create-object")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .createDefaultObject)
    }

    func testProdOnDev() throws {
        CoreEnvironment.isDebug = true
        let url = URL(string: "prod-anytype://create-object")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, nil)
    }

    func testDevOnDev() throws {
        CoreEnvironment.isDebug = true
        let url = URL(string: "dev-anytype://create-object")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .createDefaultObject)
    }
    
    func testDevOnProd() throws {
        CoreEnvironment.isDebug = false
        let url = URL(string: "dev-anytype://create-object")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, nil)
    }

    func testWrong() throws {
        let url = URL(string: "anytype123://create-object")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, nil)
    }
        
    func testArgs() throws {
        let url = URL(string: "anytype://invite?cid=1&key=2")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .invite(cid: "1", key: "2"))
    }
    
    func testArgsWithSlash() throws {
        let url = URL(string: "anytype://invite/?cid=1&key=2")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .invite(cid: "1", key: "2"))
    }
}
