import SwiftUI

struct MessageCircleLoadingView: View {
    var body: some View {
        MessageLoadingStateContainer {
            CircleLoadingView(Color.Control.white.opacity(0.8))
        }
        .background(.black.opacity(0.5))
    }
}

#Preview {
    MessageCircleLoadingView()
        .frame(width: 48, height: 48)
    MessageCircleLoadingView()
        .frame(width: 100, height: 100)
}
