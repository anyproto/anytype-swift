import SwiftUI

struct ChatThumbnail: View {
    let isSelected: Bool

    private var lineColor: Color { isSelected ? Color.Control.accent50 : Color.Shape.tertiary }
    private var bgColor: Color { isSelected ? Color.Control.accent25 : Color.Shape.secondary }
    private var avatarColor: Color { isSelected ? Color.Control.accent50 : Color.Shape.tertiary }

    var body: some View {
        ZStack {
            // Right-aligned message bubble (top)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(lineColor)
                .frame(width: 40, height: 12)
                .position(x: 60, y: 30)

            // Left-aligned bubble with avatar
            HStack(spacing: 4) {
                Circle()
                    .fill(avatarColor)
                    .frame(width: 12, height: 12)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(bgColor)
                    .frame(width: 40, height: 44)
            }
            .position(x: 40, y: 72)

            // Right-aligned bubble (bottom)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(lineColor)
                .frame(width: 40, height: 32)
                .position(x: 60, y: 126)

            // Left-aligned small bubble + avatar
            HStack(spacing: 4) {
                Circle()
                    .fill(avatarColor)
                    .frame(width: 12, height: 12)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(bgColor)
                    .frame(width: 40, height: 12)
            }
            .position(x: 40, y: 158)
        }
    }
}

#Preview {
    ChatThumbnail(isSelected: false)
    ChatThumbnail(isSelected: true)
}
