import Foundation
import AnytypeCore

public protocol DeepLinkParserProtocol: AnyObject {
    func parse(url: URL) -> DeepLink?
    func createUrl(deepLink: DeepLink, scheme: DeepLinkScheme) -> URL?
}

public final class DeepLinkParser: DeepLinkParserProtocol {

    private enum LinkPaths {
        static let createObject = "create-object"
        static let sharingExtenstion = "sharing-extension"
        static let spaceSelection = "space-selection"
        static let galleryImport = "main/import"
        static let invite = "invite"
    }

    public func parse(url: URL) -> DeepLink? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        
        let queryItems = components.queryItems ?? []
        components.queryItems = nil
        
        // Remove last /
        
        guard var urlString = components.url?.absoluteString else { return nil }
        if urlString.last == "/" {
            _ = urlString.removeLast()
        }
        
        // Check and remove schema
        
        if urlString.hasPrefix(DeepLinkScheme.buildSpecific.host()) {
            urlString = String(urlString.dropFirst(DeepLinkScheme.buildSpecific.host().count))
        } else if urlString.hasPrefix(DeepLinkScheme.main.host()) {
            urlString = String(urlString.dropFirst(DeepLinkScheme.main.host().count))
        } else {
            return nil
        }
        
        // Parse path
        
        switch urlString {
        case LinkPaths.createObject:
            return .createDefaultObject
        case LinkPaths.sharingExtenstion:
            return .showSharingExtension
        case LinkPaths.spaceSelection:
            return .spaceSelection
        case LinkPaths.galleryImport:
            guard let type = queryItems.itemValue(key: "type"),
                  let source = queryItems.itemValue(key: "source") else { return nil }
            return .galleryImport(type: type, source: source)
        case LinkPaths.invite:
            guard let cid = queryItems.itemValue(key: "cid"),
                  let key = queryItems.itemValue(key: "key") else { return nil }
            return .invite(cid: cid, key: key)
        default:
            return nil
        }
    }
    
    public func createUrl(deepLink: DeepLink, scheme: DeepLinkScheme) -> URL? {
        guard var components = URLComponents(string: scheme.host()) else { return nil }
        
        switch deepLink {
        case .createDefaultObject:
            components.path = LinkPaths.createObject
        case .showSharingExtension:
            components.path = LinkPaths.sharingExtenstion
        case .spaceSelection:
            components.path = LinkPaths.spaceSelection
        case .galleryImport(let type, let source):
            components.path = LinkPaths.galleryImport
            components.queryItems = [
                URLQueryItem(name: "type", value: type),
                URLQueryItem(name: "source", value: source)
            ]
        case .invite(let cid, let key):
            components.path = LinkPaths.invite
            components.queryItems = [
                URLQueryItem(name: "cid", value: cid),
                URLQueryItem(name: "key", value: key)
            ]
        }
        
        return components.url
    }

}
