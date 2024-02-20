import Foundation
import AnytypeCore

protocol DeepLinkParserProtocol: AnyObject {
    func parse(url: URL) -> DeepLink?
    func createUrl(deepLink: DeepLink) -> URL?
}

final class DeepLinkParser: DeepLinkParserProtocol {

    private enum LinkPaths {
        static let createObject = "create-object"
        static let sharingExtenstion = "sharing-extension"
        static let spaceSelection = "space-selection"
        static let galleryImport = "main/import"
        static let invite = "invite"
    }
    
    private enum Scheme {
        static let dev = "dev-anytype://"
        static let prod = "prod-anytype://"
        static let main = "anytype://"
    }

    func parse(url: URL) -> DeepLink? {
//        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
//        
//        let queryItems = components.queryItems
//        components.queryItems = nil
//        
//        guard var urlString = components.url?.absoluteString else { return nil }
//        if urlString.last == "/" {
//            _ = urlString.removeLast()
//        }
//        
//        switch URL(string: urlString)?.path {
//        case LinkPaths.createObject:
//            return .createDefaultObject
//        case LinkPaths.sharingExtenstion:
//            return .showSharingExtension
//        case LinkPaths.spaceSelection:
//            return .spaceSelection
//        case LinkPaths.galleryImport:
//            guard let source = queryItems?.first(where: { $0.name == "source" })?.value,
//                  let type = queryItems?.first(where: { $0.name == "type" })?.value else { return nil }
//            return .galleryImport(type: type, source: source)
//        case LinkPaths.invite:
//            guard let cid = queryItems?.first(where: { $0.name == "cid" })?.value,
//                  let key = queryItems?.first(where: { $0.name == "key" })?.value else { return nil }
//            return .invite(cid: cid, key: key)
//        default:
//            return nil
//        }
        return nil
    }
    
    func createUrl(deepLink: DeepLink) -> URL? {
//        switch deepLink {
//        case .createDefaultObject:
//            return nil
//        case .createObject:
//            return nil
//        case .showSharingExtension:
//            return nil
//        case .spaceSelection:
//            return nil
//        case .galleryImport:
//            return nil
//        case .invite(let cid, let key):
//            guard let url = URLConstants.inviteURL,
//                  var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
//            components.queryItems = [
//                URLQueryItem(name: "cid", value: cid),
//                URLQueryItem(name: "key", value: key)
//            ]
//            
//            return components.url
//        }
        
        return nil
    }
    
    private func currentDebugSchema() -> String {
        return CoreEnvironment.isDebug ? Scheme.dev : Scheme.prod
    }
}
