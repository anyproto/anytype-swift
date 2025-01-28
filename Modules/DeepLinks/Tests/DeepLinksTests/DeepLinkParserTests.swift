import XCTest
@testable import DeepLinks

final class DeepLinkParserTests: XCTestCase {

    override func tearDownWithError() throws {
    }

    func testNormalOnProd() throws {
        let parser = DeepLinkParser(targetType: .releaseAnytype)
        
        let url = URL(string: "anytype://create-object-widget")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .createObjectFromWidget)
    }
    
    func testNormalOnDev() throws {
        let parser = DeepLinkParser(targetType: .debug)
        
        let url = URL(string: "anytype://create-object-widget")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .createObjectFromWidget)
    }
    
    func testNarmalWithSlash() throws {
        let parser = DeepLinkParser(targetType: .releaseAnytype)
        
        let url = URL(string: "anytype://create-object-widget/")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .createObjectFromWidget)
    }
    
    func testProdOnProd() throws {
        let parser = DeepLinkParser(targetType: .releaseAnytype)
        
        let url = URL(string: "prod-anytype://create-object-widget")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .createObjectFromWidget)
    }

    func testProdOnDev() throws {
        let parser = DeepLinkParser(targetType: .debug)
        
        let url = URL(string: "prod-anytype://create-object-widget")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, nil)
    }

    func testDevOnDev() throws {
        let parser = DeepLinkParser(targetType: .debug)
        
        let url = URL(string: "dev-anytype://create-object-widget")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .createObjectFromWidget)
    }
    
    func testDevOnProd() throws {
        let parser = DeepLinkParser(targetType: .releaseAnytype)
        
        let url = URL(string: "dev-anytype://create-object-widget")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, nil)
    }

    func testWrong() throws {
        let parser = DeepLinkParser(targetType: .releaseAnytype)
        
        let url = URL(string: "anytype123://create-object-widget")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, nil)
    }
        
    func testArgs() throws {
        let parser = DeepLinkParser(targetType: .releaseAnytype)
        
        let url = URL(string: "anytype://invite?cid=1&key=2")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .invite(cid: "1", key: "2"))
    }
    
    func testArgsWithSlash() throws {
        let parser = DeepLinkParser(targetType: .releaseAnytype)
        
        let url = URL(string: "anytype://invite/?cid=1&key=2")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .invite(cid: "1", key: "2"))
    }
    
    func testDeepLinkToURLMainInProd() throws {
        let parser = DeepLinkParser(targetType: .releaseAnytype)
        
        let url = parser.createUrl(deepLink: .createObjectFromWidget, scheme: .main)
        XCTAssertEqual(url, URL(string: "anytype://create-object-widget"))
    }
    
    func testDeepLinkToURLMainInDev() throws {
        let parser = DeepLinkParser(targetType: .debug)
        
        let url = parser.createUrl(deepLink: .createObjectFromWidget, scheme: .main)
        XCTAssertEqual(url, URL(string: "anytype://create-object-widget"))
    }
    
    func testDeepLinkToURLSpecificInProd() throws {
        let parser = DeepLinkParser(targetType: .releaseAnytype)
        
        let url = parser.createUrl(deepLink: .createObjectFromWidget, scheme: .buildSpecific)
        XCTAssertEqual(url, URL(string: "prod-anytype://create-object-widget"))
    }
    
    func testDeepLinkToURLSpecificInDev() throws {
        let parser = DeepLinkParser(targetType: .debug)
        
        let url = parser.createUrl(deepLink: .createObjectFromWidget, scheme: .buildSpecific)
        XCTAssertEqual(url, URL(string: "dev-anytype://create-object-widget"))
    }
    
    func testDeepLinkWithArgs() throws {
        let parser = DeepLinkParser(targetType: .releaseAnytype)
        
        let url = parser.createUrl(deepLink: .galleryImport(type: "1", source: "2"), scheme: .main)
        XCTAssertEqual(url, URL(string: "anytype://main/import?type=1&source=2"))
    }
}
