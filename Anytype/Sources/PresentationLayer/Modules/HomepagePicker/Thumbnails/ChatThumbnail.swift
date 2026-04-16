import SwiftUI

struct ChatThumbnail: View {

    private var lineColor: Color { Color.Control.accent50 }
    private var backgroundColor: Color { Color.Shape.secondary }
    private var avatarColor: Color { Color.Control.tertiary }

    var body: some View {
        ZStack {
            // 1. Small right bubble (top)
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(lineColor)
                .frame(width: 40, height: 12)
                .position(x: 40 + 20, y: 20 + 6)

            // 2. Left bubble
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(backgroundColor)
                .frame(width: 48, height: 12)
                .position(x: 24 + 24, y: 36 + 6)

            // 3. Left tall bubble (image placeholder)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(backgroundColor)
                .frame(width: 40, height: 44)
                .position(x: 24 + 20, y: 52 + 22)

            // 4. Avatar circle (left, aligned with tall bubble)
            Circle()
                .fill(avatarColor)
                .frame(width: 12, height: 12)
                .position(x: 8 + 6, y: 84 + 6)

            // 5. Right bubble
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(lineColor)
                .frame(width: 48, height: 12)
                .position(x: 32 + 24, y: 100 + 6)

            // 6. Right tall bubble
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(lineColor)
                .frame(width: 40, height: 32)
                .position(x: 40 + 20, y: 116 + 16)

            // 7. Avatar circle (bottom left)
            Circle()
                .fill(avatarColor)
                .frame(width: 12, height: 12)
                .position(x: 8 + 6, y: 152 + 6)

            // 8. Left bubble next to bottom avatar
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(backgroundColor)
                .frame(width: 40, height: 12)
                .position(x: 24 + 20, y: 152 + 6)
        }
    }
}

#Preview {
    ChatThumbnail().frame(height: 172)
}
