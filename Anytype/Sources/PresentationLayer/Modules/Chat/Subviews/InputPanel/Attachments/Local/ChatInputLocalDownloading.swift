import SwiftUI

struct ChatInputLocalDownloading: View {
    
    let onTapRemove: () -> Void
    
    var body: some View {
        MessageCircleLoadingView()
        .frame(width: 72, height: 72)
        .background(Color.Background.secondary)
        .messageLinkStyle()
        .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}
