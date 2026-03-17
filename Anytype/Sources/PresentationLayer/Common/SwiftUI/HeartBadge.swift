import SwiftUI

struct HeartBadge: View {

    let style: MentionBadgeStyle

    var body: some View {
        Image(systemName: "heart.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 10, height: 10)
            .foregroundStyle(Color.Control.white)
            .frame(width: 20, height: 20)
            .background(
                Capsule()
                    .fill(fillColor)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            )
    }

    private var fillColor: Color {
        switch style {
        case .muted: return Color.Control.transparentTertiary
        case .highlighted: return Color.Pure.red
        }
    }
}
