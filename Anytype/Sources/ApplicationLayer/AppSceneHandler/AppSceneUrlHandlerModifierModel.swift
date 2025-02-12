import Foundation
import SwiftUI
import DeepLinks
import AnytypeCore

@MainActor
final class AppSceneUrlHandlerModifierModel: ObservableObject {
    
    @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    @Injected(\.universalLinkParser)
    private var universalLinkParser: any UniversalLinkParserProtocol
    @Injected(\.deepLinkParser)
    private var deepLinkParser: any DeepLinkParserProtocol
    
    @Published var safariUrl: URL?
    
    func onOpenURL(_ url: URL) -> Bool {
        let urlWithScheme = url.urlByAddingHttpIfSchemeIsEmpty()
        
        if let deepLink = deepLinkParser.parse(url: urlWithScheme) {
            appActionStorage.action = .deepLink(deepLink)
            return true
        }
        
        if let link = universalLinkParser.parse(url: urlWithScheme) {
            appActionStorage.action = .deepLink(link.toDeepLink())
            return true
        }
        
        if urlWithScheme.host() == AppLinks.storeHost {
            return false
        }
        
        if urlWithScheme.containsHttpProtocol {
            safariUrl = urlWithScheme
            return true
        }
       
        return false
    }
}
