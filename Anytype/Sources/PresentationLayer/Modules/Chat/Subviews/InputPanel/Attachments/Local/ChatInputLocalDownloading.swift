import SwiftUI

struct ChatInputLocalDownloading: View {
    
    let onTapRemove: () -> Void
    
    var body: some View {
        ZStack {
            MessageCircleLoadingView()
                .frame(width: 32, height: 32)
        }
        .frame(width: 72, height: 72)
        .background(Color.Background.secondary)
        .messageLinkStyle()
        .messageLinkRemoveButton(onTapRemove: onTapRemove)
    }
}
