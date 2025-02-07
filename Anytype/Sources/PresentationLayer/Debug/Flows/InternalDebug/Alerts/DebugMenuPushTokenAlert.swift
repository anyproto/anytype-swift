import SwiftUI

struct DebugMenuPushTokenAlert: View {
    
    let token: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(title: "Your push token", message: token) {
            BottomAlertButton(text: "Copy", style: .primary) {
                UIPasteboard.general.string = token
            }
            BottomAlertButton(text: "Close", style: .secondary) {
                dismiss()
            }
        }
    }
}
