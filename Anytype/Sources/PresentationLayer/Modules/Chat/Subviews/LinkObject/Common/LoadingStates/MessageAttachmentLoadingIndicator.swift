import SwiftUI

struct MessageAttachmentLoadingIndicator: View {
    
    var body: some View {
        MessageCircleLoadingView()
            .background(Color.Shape.tertiary)
    }
}

#Preview {
    MessageAttachmentLoadingIndicator()
        .frame(width: 100, height: 100)
}
