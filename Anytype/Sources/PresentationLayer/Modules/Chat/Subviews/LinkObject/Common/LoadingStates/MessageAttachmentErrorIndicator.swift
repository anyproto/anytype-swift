import SwiftUI

struct MessageAttachmentErrorIndicator: View {
    
    var body: some View {
        MessageErrorView()
            .background(Color.Shape.tertiary)
    }
}

#Preview {
    MessageAttachmentErrorIndicator()
        .frame(width: 100, height: 100)
}
