import Foundation

protocol DeepLinkParserProtocol: AnyObject {
    func parse(url: URL) -> AppAction?
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
            return .createObject
        case URLConstants.sharingExtenstionURL:
            return .showSharingExtension
        case URLConstants.spaceSelectionURL:
            return .spaceSelection
        case URLConstants.galleryImportURL:
            guard let source = queryItems?.first(where: { $0.name == "source" })?.value,
                  let type = queryItems?.first(where: { $0.name == "type" })?.value else { return nil }
            return .galleryImport(type: type, source: source)
        default:
            return nil
        }
    }
}
