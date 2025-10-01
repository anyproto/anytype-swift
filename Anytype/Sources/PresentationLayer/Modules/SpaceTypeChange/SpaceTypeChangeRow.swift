import SwiftUI
import DesignKit

struct SpaceTypeChangeRow: View {
    
    let icon: ImageAsset
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onTap: () async throws -> Void
    
    var body: some View {
        AsyncButton {
            try await onTap()
        } label: {
            HStack(spacing: 12) {
                Image(asset: icon)
                    .frame(width: 48, height: 48)
                    .background {
                        Circle().foregroundStyle(Color.Shape.transperentSecondary)
                    }
                VStack(alignment: .leading, spacing: 0) {
                    AnytypeText(title, style: .uxTitle2Medium)
                        .foregroundColor(.Text.primary)
                        .lineLimit(1)
                    AnytypeText(subtitle, style: .relation3Regular)
                        .foregroundColor(.Text.secondary)
                        .lineLimit(2)
                }
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if isSelected {
                    Image(asset: .X24.tick)
                }
            }
            .frame(height: 72)
            .newDivider()
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    SpaceTypeChangeRow(
        icon: .X24.chat,
        title: "Chat",
        subtitle: "Group chat with shared data. Best for small groups or a single ongoing conversation.",
        isSelected: true
    ) {}
    
    SpaceTypeChangeRow(
        icon: .X24.space,
        title: "Space",
        subtitle: "Hub for advanced data management. Multi-chats by topic coming soon. Ideal for larger teams.",
        isSelected: false
    ) {}
}
