import Foundation


public protocol DeepLinkParserProtocol: AnyObject, Sendable {
    func parse(url: URL) -> DeepLink?
    func createUrl(deepLink: DeepLink, scheme: DeepLinkScheme) -> URL?
}

final class DeepLinkParser: DeepLinkParserProtocol, Sendable {

    private enum LinkPaths {
        static let createObjectWidget = "create-object-widget"
        static let sharingExtenstion = "sharing-extension"
        static let galleryImport = "main/import"
        static let invite = "invite"
        static let object = "object"
        static let membership = "membership"
        static let networkConfig = "networkConfig"
    }

    private let isDebug: Bool
    
    init(isDebug: Bool) {
        self.isDebug = isDebug
    }
    
    public func parse(url: URL) -> DeepLink? {
        let urlString = url.absoluteString.replacingHTMLEntities
        guard var components = URLComponents(string: urlString) else { return nil }
        
        let queryItems = components.queryItems ?? []
        components.queryItems = nil
        
        // Remove last /
        
        guard var urlString = components.url?.absoluteString else { return nil }
        if urlString.last == "/" {
            _ = urlString.removeLast()
        }
        
        // Check and remove schema
        
        if urlString.hasPrefix(DeepLinkScheme.buildSpecific.host(isDebug: isDebug)) {
            urlString = String(urlString.dropFirst(DeepLinkScheme.buildSpecific.host(isDebug: isDebug).count))
        } else if urlString.hasPrefix(DeepLinkScheme.main.host(isDebug: isDebug)) {
            urlString = String(urlString.dropFirst(DeepLinkScheme.main.host(isDebug: isDebug).count))
        } else {
            return nil
        }
        
        // Parse path
        
        switch urlString {
        case LinkPaths.createObjectWidget:
            return .createObjectFromWidget
        case LinkPaths.sharingExtenstion:
            return .showSharingExtension
        case LinkPaths.galleryImport:
            guard let type = queryItems.stringValue(key: "type"),
                  let source = queryItems.stringValue(key: "source") else { return nil }
            return .galleryImport(type: type, source: source)
        case LinkPaths.invite:
            guard let cid = queryItems.stringValue(key: "cid"),
                  let key = queryItems.stringValue(key: "key") else { return nil }
            return .invite(cid: cid, key: key)
        case LinkPaths.object:
            guard let objectId = queryItems.stringValue(key: "objectId"),
                  let spaceId = queryItems.stringValue(key: "spaceId") else { return nil }
            let cid = queryItems.stringValue(key: "cid")
            let key = queryItems.stringValue(key: "key")
            return .object(objectId: objectId, spaceId: spaceId, cid: cid, key: key)
        case LinkPaths.membership:
            guard let tier = queryItems.intValue(key: "tier") else { return nil }
            return .membership(tierId: tier)
        case LinkPaths.networkConfig:
            guard let config = queryItems.stringValue(key: "config") else { return nil }
            return .networkConfig(config: config)
        default:
            return nil
        }
    }
    
    public func createUrl(deepLink: DeepLink, scheme: DeepLinkScheme) -> URL? {
        
        let host = scheme.host(isDebug: isDebug)
        
        switch deepLink {
        case .createObjectFromWidget:
            return URL(string: host + LinkPaths.createObjectWidget)
        case .showSharingExtension:
            return URL(string: host + LinkPaths.sharingExtenstion)
        case .galleryImport(let type, let source):
            guard var components = URLComponents(string: host + LinkPaths.galleryImport) else { return nil }
            components.queryItems = [
                URLQueryItem(name: "type", value: type),
                URLQueryItem(name: "source", value: source)
            ]
            return components.url
        case .invite(let cid, let key):
            guard var components = URLComponents(string: host + LinkPaths.invite) else { return nil }
            components.queryItems = [
                URLQueryItem(name: "cid", value: cid),
                URLQueryItem(name: "key", value: key)
            ]
            
            return components.url
        case let .object(objectId, spaceId, cid, key):
            guard var components = URLComponents(string: host + LinkPaths.object) else { return nil }
            components.queryItems = [
                URLQueryItem(name: "objectId", value: objectId),
                URLQueryItem(name: "spaceId", value: spaceId),
                URLQueryItem(name: "cid", value: cid),
                URLQueryItem(name: "key", value: key)
            ]
            
            return components.url
        case .membership(let tierId):
            guard var components = URLComponents(string: host + LinkPaths.membership) else { return nil }
            components.queryItems = [
                URLQueryItem(name: "tier", value: String(tierId)),
            ]
            
            return components.url
        case .networkConfig(let config):
            guard var components = URLComponents(string: host + LinkPaths.networkConfig) else { return nil }
            components.queryItems = [
                URLQueryItem(name: "config", value: config)
            ]
            
            return components.url
        }
    }

}
