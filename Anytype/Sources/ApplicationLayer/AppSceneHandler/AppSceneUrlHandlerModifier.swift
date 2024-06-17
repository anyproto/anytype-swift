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
    }
}

extension View {
    func setupAppSceneUrlHandler() -> some View {
        modifier(AppSceneUrlHandlerModifier())
    }
}
