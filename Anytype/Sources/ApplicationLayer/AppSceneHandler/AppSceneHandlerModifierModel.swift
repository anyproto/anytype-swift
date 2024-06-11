import Foundation
import SwiftUI
import DeepLinks

@MainActor
final class AppSceneHandlerModifierModel: ObservableObject {
    
    @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    @Injected(\.universalLinkParser)
    private var universalLinkParser: UniversalLinkParserProtocol
    @Injected(\.deepLinkParser)
    private var deepLinkParser: DeepLinkParserProtocol
    
    func onOpenURL(_ url: URL) {
        guard let deepLink = deepLinkParser.parse(url: url) else { return }
        appActionStorage.action = .deepLink(deepLink)
    }
    
    func onContinueWebUserActivity(_ userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL,
              let link = universalLinkParser.parse(url: url) else { return }
        
        appActionStorage.action = .deepLink(link.toDeepLink())
    }
}
