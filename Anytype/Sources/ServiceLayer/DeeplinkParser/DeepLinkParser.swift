import Foundation

protocol DeepLinkParserProtocol: AnyObject {
    func parse(url: URL) -> AppAction?
    func createUrl(deepLink: AppAction) -> URL?
}

final class DeepLinkParser: DeepLinkParserProtocol {
    
    func parse(url: URL) -> AppAction? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        
        let queryItems = components.queryItems
        components.queryItems = nil
        
        guard var urlString = components.url?.absoluteString else { return nil }
        if urlString.last == "/" {
            _ = urlString.removeLast()
        }
        
        switch URL(string: urlString) {
        case URLConstants.createObjectURL:
            return .createObjectFromWidget
        case URLConstants.sharingExtenstionURL:
            return .showSharingExtension
        case URLConstants.spaceSelectionURL:
            return .spaceSelection
        case URLConstants.galleryImportURL:
            guard let source = queryItems?.first(where: { $0.name == "source" })?.value,
                  let type = queryItems?.first(where: { $0.name == "type" })?.value else { return nil }
            return .galleryImport(type: type, source: source)
        case URLConstants.inviteURL:
            guard let cid = queryItems?.first(where: { $0.name == "cid" })?.value,
                  let key = queryItems?.first(where: { $0.name == "key" })?.value else { return nil }
            return .invite(cid: cid, key: key)
        default:
            return nil
        }
    }
    
    func createUrl(deepLink: AppAction) -> URL? {
        switch deepLink {
        case .createObjectFromWidget:
            return nil
        case .createObjectFromQuickAction:
            return nil
        case .showSharingExtension:
            return nil
        case .spaceSelection:
            return nil
        case .galleryImport:
            return nil
        case .invite(let cid, let key):
            guard let url = URLConstants.inviteURL,
                  var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
            components.queryItems = [
                URLQueryItem(name: "cid", value: cid),
                URLQueryItem(name: "key", value: key)
            ]
            
            return components.url
        }
    }
}
