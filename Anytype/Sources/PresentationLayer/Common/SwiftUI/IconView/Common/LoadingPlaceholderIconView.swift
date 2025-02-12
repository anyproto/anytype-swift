import SwiftUI

struct LoadingPlaceholderIconView: View {
    var body: some View {
        Image(uiImage: UIImage(ciImage: .empty()))
            .resizable()
            .scaledToFill()
            .redacted(reason: .placeholder)
    }
}
