import Foundation
import SwiftUI
import DeepLinks
import AnytypeCore

@MainActor
final class AppSceneUrlHandlerModifierModel: ObservableObject {
    
    @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    @Injected(\.universalLinkParser)
    private var universalLinkParser: UniversalLinkParserProtocol
    @Injected(\.deepLinkParser)
    private var deepLinkParser: DeepLinkParserProtocol
    
    func onOpenURL(_ url: URL) -> Bool {
        if let deepLink = deepLinkParser.parse(url: url) {
            appActionStorage.action = .deepLink(deepLink)
            return true
        }
        
        if let link = universalLinkParser.parse(url: url) {
            appActionStorage.action = .deepLink(link.toDeepLink())
            return true
        }
        
        return false
    }
}
