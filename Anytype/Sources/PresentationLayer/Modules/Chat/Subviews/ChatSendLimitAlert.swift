import Foundation
import SwiftUI

struct ChatSendLimitAlert: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(
            title: Loc.Chat.SendLimitAlert.title,
            message: Loc.Chat.SendLimitAlert.message,
            icon: .BottomAlert.exclamation
        ) {
            BottomAlertButton(text: Loc.okay, style: .secondary) {
                dismiss()
            }
        }
    }
}
