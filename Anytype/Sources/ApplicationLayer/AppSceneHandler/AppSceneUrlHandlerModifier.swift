import Foundation
import SwiftUI
import DesignKit

private struct AppSceneUrlHandlerModifier: ViewModifier {
    
    @StateObject private var model = AppSceneUrlHandlerModifierModel()
    @State private var toast: ToastBarData?
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                if model.onOpenURL(url) {
                    return .handled
                }
                if !UIApplication.shared.canOpenURL(url) {
                    UIPasteboard.general.string = url.absoluteString
                    toast = ToastBarData(Loc.copiedToClipboard(url.absoluteString))
                }
                return .systemAction(url)
            })
            // Universal links on web site and external deep links
            .onOpenURL { url in
                _ = model.onOpenURL(url, source: .external)
            }
            // When user scan qr code
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                guard let url = userActivity.webpageURL else {
                    return
                }
                _ = model.onOpenURL(url)
            }
            .safariSheet(url: $model.safariUrl)
            .snackbar(toastBarData: $toast)
    }
}

extension View {
    func setupAppSceneUrlHandler() -> some View {
        modifier(AppSceneUrlHandlerModifier())
    }
}
