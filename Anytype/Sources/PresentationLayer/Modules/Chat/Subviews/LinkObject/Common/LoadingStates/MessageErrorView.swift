import SwiftUI

struct MessageErrorView: View {
    var body: some View {
        Image(asset: .Dialog.exclamation)
            .renderingMode(.template)
            .resizable()
            .foregroundStyle(Color.Control.transparentActive)
            .background(Circle().foregroundStyle(.ultraThinMaterial))
            .proportionalPadding(padding: 2, side: 52)
    }
}
