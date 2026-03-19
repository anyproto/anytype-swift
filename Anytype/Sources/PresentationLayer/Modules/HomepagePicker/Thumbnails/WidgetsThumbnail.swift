import SwiftUI

struct WidgetsThumbnail: View {
    let isSelected: Bool

    private var lineColor: Color { isSelected ? Color.Control.accent50 : Color.Shape.tertiary }
    private var cardBg: Color { isSelected ? Color.Control.accent25 : Color.Shape.transparentTertiary }

    var body: some View {
        VStack(spacing: 6) {
            widgetCard(rowPattern: [22, 54, 36, 54], height: 52)
            statusBar
            widgetCard(rowPattern: [22, 54, 36, 54, 36], height: 64)
        }
        .padding(6)
    }

    private func widgetCard(rowPattern: [CGFloat], height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rowPattern.enumerated()), id: \.offset) { index, width in
                if index == 0 {
                    // Title line (no dot)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(lineColor)
                        .frame(width: width, height: 4)
                        .padding(.top, 5)
                } else {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(lineColor)
                            .frame(width: 6, height: 6)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(lineColor)
                            .frame(width: width, height: 4)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .background(cardBg.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var statusBar: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(lineColor)
                .frame(width: 6, height: 6)
            RoundedRectangle(cornerRadius: 3)
                .fill(lineColor)
                .frame(width: 36, height: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 6)
        .frame(height: 16)
        .background(cardBg.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
