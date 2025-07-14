import SwiftUI

struct MessageNetworkErrorAlert: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        BottomAlertView(
            title: Loc.Chat.FileSyncError.Network.title,
            message: Loc.Chat.FileSyncError.Network.description
        ) {
            BottomAlertButton(text: Loc.Chat.FileSyncError.Network.done, style: .secondary) {
                dismiss()
            }
        }
    }
}

#Preview {
    MessageNetworkErrorAlert()
}
