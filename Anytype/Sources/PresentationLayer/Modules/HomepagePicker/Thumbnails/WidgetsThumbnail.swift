import SwiftUI

struct WidgetsThumbnail: View {
    let isSelected: Bool

    private var lineColor: Color { isSelected ? Color.Control.accent50 : Color.Shape.tertiary }
    private var cardBg: Color { isSelected ? Color.Control.accent25 : Color.Shape.transparentTertiary }

    var body: some View {
        VStack(spacing: 6) {
            widgetCard(rows: 3, height: 52)
            statusBar
            widgetCard(rows: 4, height: 64)
        }
        .padding(6)
    }

    private func widgetCard(rows: Int, height: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<rows, id: \.self) { index in
                HStack(spacing: 4) {
                    Circle()
                        .fill(lineColor)
                        .frame(width: 6, height: 6)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(lineColor)
                        .frame(width: index == rows - 1 ? 36 : 54, height: 4)
                }
                .padding(.vertical, 3)
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .background(cardBg)
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
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
