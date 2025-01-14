import SwiftUI

struct ChatCreateObjectDiscardAlert: View {
    
    let onTapConfirm: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(
            title: "All changes will be discarded.",
            buttons: {
                BottomAlertButton(text: Loc.cancel, style: .secondary, action: {
                    dismiss()
                })
                BottomAlertButton(text: Loc.ok, style: .primary, action: {
                    onTapConfirm()
                })
            }
        )
    }
}
