import SwiftUI

struct MessageCircleLoadingView: View {
    var body: some View {
        CircleLoadingView(.Control.transparentActive)
            .backgroundStyle(.ultraThinMaterial)
    }
}
