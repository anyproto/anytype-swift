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

    func testNormalOnProd() throws {
        CoreEnvironment.isDebug = false
        let url = URL(string: "anytype://create-object")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .createDefaultObject)
    }
    
    func testNormalOnDev() throws {
        CoreEnvironment.isDebug = true
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
    
    func testDeepLinkToURLMainInProd() throws {
        CoreEnvironment.isDebug = false
        
        let url = parser.createUrl(deepLink: .createDefaultObject, scheme: .main)
        XCTAssertEqual(url, URL(string: "anytype://create-object"))
    }
    
    func testDeepLinkToURLMainInDev() throws {
        CoreEnvironment.isDebug = true
        
        let url = parser.createUrl(deepLink: .createDefaultObject, scheme: .main)
        XCTAssertEqual(url, URL(string: "anytype://create-object"))
    }
    
    func testDeepLinkToURLSpecificInProd() throws {
        CoreEnvironment.isDebug = false
        
        let url = parser.createUrl(deepLink: .createDefaultObject, scheme: .buildSpecific)
        XCTAssertEqual(url, URL(string: "prod-anytype://create-object"))
    }
    
    func testDeepLinkToURLSpecificInDev() throws {
        CoreEnvironment.isDebug = true
        
        let url = parser.createUrl(deepLink: .createDefaultObject, scheme: .buildSpecific)
        XCTAssertEqual(url, URL(string: "dev-anytype://create-object"))
    }
    
    func testDeepLinkWithArgs() throws {
        let url = parser.createUrl(deepLink: .galleryImport(type: "1", source: "2"), scheme: .main)
        XCTAssertEqual(url, URL(string: "anytype://main/import?type=1&source=2"))
    }
}
