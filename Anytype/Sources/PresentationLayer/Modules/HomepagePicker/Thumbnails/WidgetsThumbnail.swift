import SwiftUI

struct WidgetsThumbnail: View {

    private var lineColor: Color { Color.Control.tertiary }
    private var cardBackground: Color { Color.Shape.transparentTertiary }

    var body: some View {
        VStack(spacing: 6) {
            widgetCard(rowPattern: [22, 54, 36, 54])
            widgetCard(rowPattern: [36])
            widgetCard(rowPattern: [22, 54, 36, 54, 36])
        }
        .padding(6)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    private func widgetCard(rowPattern: [CGFloat]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(rowPattern.enumerated()), id: \.offset) { _, width in
                HStack(spacing: 4) {
                    Circle()
                        .fill(lineColor)
                        .frame(width: 6, height: 6)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(lineColor)
                        .frame(width: width, height: 4)
                }
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    WidgetsThumbnail().frame(height: 172)
}
