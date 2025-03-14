import Foundation
import AnytypeCore

protocol UniversalLinkParserProtocol: AnyObject {
    func parse(url: URL) -> UniversalLink?
    func createUrl(link: UniversalLink) -> URL?
}

final class UniversalLinkParser: UniversalLinkParserProtocol {

    private enum LinkPaths {
        static let inviteHostProd = "invite.any.coop"
        static let inviteHostStage = "invite-stage.any.coop"
        static let inviteHosts = [inviteHostProd, inviteHostStage]
        static let objectHost = "object.any.coop"
    }
    
    func parse(url: URL) -> UniversalLink? {
        guard let components = NSURLComponents(string: url.absoluteString.removingPercentEncoding ?? url.absoluteString) else { return nil }
        
        // Link: https://invite.any.coop/<inviteId>#<encryptionkey>
        if let host = components.host, LinkPaths.inviteHosts.contains(host), var path = components.path, let fragment = components.fragment {
            
            if path.hasPrefix("/") {
                path.removeFirst(1)
            }
            
            guard path.isNotEmpty, fragment.isNotEmpty else {
                return nil
            }
            
            return .invite(cid: path, key: fragment)
        }
        
        // Link: https://object.any.coop/<objectId>?spaceId=<spaceId>&inviteId=<inviteId>#<encryptionKey>
        if let host = components.host, host == LinkPaths.objectHost, var objectId = components.path {
            
            if objectId.hasPrefix("/") {
                objectId.removeFirst(1)
            }
            
            let queryItems = components.queryItems ?? []
            
            guard let spaceId = queryItems.stringValue(key: "spaceId") else {
                return nil
            }
            let cid = queryItems.stringValue(key: "inviteId")
            let key = components.fragment
            
            return .object(objectId: objectId, spaceId: spaceId, cid: cid, key: key)
        }
        
        return nil
    }
    
    func createUrl(link: UniversalLink) -> URL? {
        switch link {
        case .invite(let cid, let key):
            return URL(string: "https://\(LinkPaths.inviteHostProd)/\(cid)#\(key)")
        case let .object(objectId, spaceId, cid, key):
            let componentsString = "https://\(LinkPaths.objectHost)/\(objectId)"
            guard var components = URLComponents(string: componentsString) else { return nil }
            components.queryItems = [
                URLQueryItem(name: "spaceId", value: spaceId),
                URLQueryItem(name: "inviteId", value: cid),
            ]
            guard let key, let absoluteString = components.url?.absoluteString else {
                return components.url
            }
            return URL(string: absoluteString + "#\(key)")
        }
    }
}
