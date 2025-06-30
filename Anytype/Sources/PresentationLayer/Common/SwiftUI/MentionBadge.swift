import SwiftUI

enum MentionBadgeStyle {
    case muted
    case highlighted
}

struct MentionBadge: View {
    
    let style: MentionBadgeStyle
      
    var body: some View {
        Text("@")
            .anytypeFontStyle(.caption1Medium) // Without line height multiple
            .foregroundStyle(Color.Control.white)
            .baselineOffset(3)
            .frame(width: 20, height: 20)
            .background(
                Capsule()
                    .fill(fillColor)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule()) // From iOS 17: Delete clip and use .fill for material
            )
    }
    
    private var fillColor: Color {
        switch style {
        case .muted: return Color.Control.inactive
        case .highlighted: return Color.System.amber125
        }
    }
}
