import SwiftUI

struct MoreIndicator: View {
    var body: some View {
        Image(asset: .X24.more)
            .foregroundStyle(Color.Text.secondary)
            .frame(width: 24, height: 24)
            .contentShape(Rectangle())
    }
}

#Preview {
    MoreIndicator()
}
