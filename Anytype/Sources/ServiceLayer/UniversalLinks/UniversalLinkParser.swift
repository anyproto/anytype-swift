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
        
        // From iOS 16 can be migrated to Regex
        
        // Link: https://invite.any.coop/<inviteId>#<encryptionkey>
        if LinkPaths.inviteHosts.contains(components.host), var path = components.path, let fragment = components.fragment {
            
            if path.hasPrefix("/") {
                path.removeFirst(1)
            }
            
            guard path.isNotEmpty, fragment.isNotEmpty else {
                logNilResult(url: url)
                return nil
            }
            
            return .invite(cid: path, key: fragment)
        }
        
        logNilResult(url: url)
        return nil
    }
    
    func createUrl(deepLink: UniversalLink) -> URL? {
        return nil
    }  
    
    private func logNilResult(url: URL) {
        anytypeAssertionFailure("Can't process universal link", info: ["url": url.absoluteString])
    }
}
