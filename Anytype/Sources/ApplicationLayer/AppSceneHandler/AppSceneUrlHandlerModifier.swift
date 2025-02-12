import Foundation
import SwiftUI

private struct AppSceneUrlHandlerModifier: ViewModifier {
    
    @StateObject private var model = AppSceneUrlHandlerModifierModel()
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                if model.onOpenURL(url) {
                    return .handled
                }
                return .systemAction(url)
            })
            // Universal links on web site and external deep links
            .onOpenURL { url in
                _ = model.onOpenURL(url)
            }
            // When user scan qr code
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                guard let url = userActivity.webpageURL else {
                    return
                }
                _ = model.onOpenURL(url)
            }
            .safariSheet(url: $model.safariUrl)
    }
}

extension View {
    func setupAppSceneUrlHandler() -> some View {
        modifier(AppSceneUrlHandlerModifier())
    }
}
