import XCTest
@testable import Anytype

final class UniversalLinkParserTests: XCTestCase {

    let parser = UniversalLinkParser()
    
    override func tearDownWithError() throws {
    }

    func testNormal() throws {
        let url = URL(string: "https://invite.any.coop/bafybeidswywdqat64gupwpnrecy2avv5yzhdbmit2skkfyv65stapd42me#D9QJW8SjXBT7QNb6yqFYE7BygwGrunwyNqMMjktKcK3b")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, .invite(cid: "bafybeidswywdqat64gupwpnrecy2avv5yzhdbmit2skkfyv65stapd42me", key: "D9QJW8SjXBT7QNb6yqFYE7BygwGrunwyNqMMjktKcK3b"))
    }
    
    func testOnlyInviteId() throws {
        let url = URL(string: "https://invite.any.coop/bafybeidswywdqat64gupwpnrecy2avv5yzhdbmit2skkfyv65stapd42me")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, nil)
    }
    
    func testOnlyInviteIdWithEmptyKeyId() throws {
        let url = URL(string: "https://invite.any.coop/bafybeidswywdqat64gupwpnrecy2avv5yzhdbmit2skkfyv65stapd42me#")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, nil)
    }
    
    func testOnlyKeyId() throws {
        let url = URL(string: "https://invite.any.coop#D9QJW8SjXBT7QNb6yqFYE7BygwGrunwyNqMMjktKcK3b")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, nil)
    }
    
    func testOnlyKeyIdWithEmptyInvite() throws {
        let url = URL(string: "https://invite.any.coop/#D9QJW8SjXBT7QNb6yqFYE7BygwGrunwyNqMMjktKcK3b")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, nil)
    }
    
    func testOnlyHostWithSlash() throws {
        let url = URL(string: "https://invite.any.coop/")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, nil)
    }
    
    func testOnlyHostWithoutSlash() throws {
        let url = URL(string: "https://invite.any.coop")!
        
        let deepLink = parser.parse(url: url)
        XCTAssertEqual(deepLink, nil)
    }
    
    func testCreateUniversalLinkURL() throws {
        let url = parser.createUrl(deepLink: .invite(cid: "1", key: "2"))
        XCTAssertEqual(url, URL(string: "https://invite.any.coop/1#2")!)
    }
}
