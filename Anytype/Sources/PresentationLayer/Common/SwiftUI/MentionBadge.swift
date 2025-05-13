import SwiftUI


struct MentionBadge: View {
      
    var body: some View {
        Text("@")
            .anytypeFontStyle(.caption1Medium) // Without line height multiple
            .foregroundStyle(Color.Control.white)
            .baselineOffset(3)
            .frame(width: 20, height: 20)
            .background(
                Capsule()
                    .fill(Color.Control.transparentActive)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule()) // From iOS 17: Delete clip and use .fill for material
            )
    }
}
