import SwiftUI

struct MessageAttachmentErrorIndicator: View {
    
    var body: some View {
        MessageErrorView(syncError: nil)
            .background(Color.Shape.tertiary)
    }
}

#Preview {
    MessageAttachmentErrorIndicator()
        .frame(width: 100, height: 100)
}
