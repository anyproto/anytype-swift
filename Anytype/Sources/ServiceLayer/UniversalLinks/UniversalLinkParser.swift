import Foundation
import AnytypeCore

protocol UniversalLinkParserProtocol: AnyObject {
    func parse(url: URL) -> UniversalLink?
    func createUrl(deepLink: UniversalLink) -> URL?
}

final class UniversalLinkParser: UniversalLinkParserProtocol {

    private enum LinkPaths {
        static let inviteHosts = ["invite.any.coop", "invite-stage.any.coop"]
    }
    
    func parse(url: URL) -> UniversalLink? {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        
        
        if LinkPaths.inviteHosts.contains(components.host), let path = components.path {
            let regex = try? NSRegularExpression(pattern: "(<inviteId>.+?)#(<encryptionkey>.+?)", options: .caseInsensitive)
            let match = regex?.firstMatch(in: path, range: NSRange(location: 0, length: path.count))
            
            match?.range(withName: "inviteId")
        }
        
        anytypeAssertionFailure("Can't process universal link", info: ["url": url.absoluteString])
        return nil
    }
    
    func createUrl(deepLink: UniversalLink) -> URL? {
        return nil
    }

}
