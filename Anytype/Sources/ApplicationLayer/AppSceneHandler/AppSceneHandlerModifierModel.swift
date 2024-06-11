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
        if let deepLink = deepLinkParser.parse(url: url) {
            appActionStorage.action = .deepLink(deepLink)
        }
        
        if let link = universalLinkParser.parse(url: url) {
            appActionStorage.action = .deepLink(link.toDeepLink())
        }
    }
}
