import SwiftUI

struct MessageAttachmentLoadingIndicator: View {
    
    var body: some View {
        ZStack {
            MessageCircleLoadingView()
                .frame(width: 52, height: 52, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.Shape.tertiary)
    }
}
