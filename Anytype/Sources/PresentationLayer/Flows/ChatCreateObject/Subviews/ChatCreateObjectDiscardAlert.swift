import SwiftUI

struct ChatCreateObjectDiscardAlert: View {
    
    let onTapConfirm: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(
            title: Loc.Chat.CreateObject.Dismiss.title,
            message: Loc.Chat.CreateObject.Dismiss.message,
            buttons: {
                BottomAlertButton(text: Loc.cancel, style: .secondary, action: {
                    dismiss()
                })
                BottomAlertButton(text: Loc.Chat.CreateObject.Dismiss.ok, style: .warning, action: {
                    onTapConfirm()
                })
            }
        )
    }
}
