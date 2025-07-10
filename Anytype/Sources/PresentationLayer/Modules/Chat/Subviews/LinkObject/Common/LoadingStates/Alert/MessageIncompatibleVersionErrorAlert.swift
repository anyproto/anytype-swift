import SwiftUI

struct MessageIncompatibleVersionErrorAlert: View {
    
    @State private var url: URL?
    
    var body: some View {
        BottomAlertView(
            title: Loc.Chat.FileSyncError.IncompatibleVersion.title,
            message: Loc.Chat.FileSyncError.IncompatibleVersion.description
        ) {
            BottomAlertButton(text: Loc.Chat.FileSyncError.IncompatibleVersion.action, style: .primary) {
                url = AppLinks.storeLink
            }
        }
        .openUrl(url: $url)
    }
}

#Preview {
    MessageIncompatibleVersionErrorAlert()
}
