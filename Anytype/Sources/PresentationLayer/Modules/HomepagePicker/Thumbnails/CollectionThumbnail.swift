import SwiftUI

struct CollectionThumbnail: View {
    let isSelected: Bool

    private var lineColor: Color { isSelected ? Color.Control.accent50 : Color.Shape.tertiary }
    private var accentDot: Color { isSelected ? Color.Control.accent100 : Color.Shape.tertiary }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // "Tasks" title placeholder
            RoundedRectangle(cornerRadius: 2)
                .fill(lineColor)
                .frame(width: 40, height: 11)
                .padding(.top, 30)

            // Header row: subtitle line + toggle pill
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(lineColor)
                    .frame(width: 32, height: 4)
                Spacer()
                Capsule()
                    .fill(accentDot)
                    .frame(width: 20, height: 10)
            }
            .padding(.top, 6)

            // 4 row groups (alternating line widths)
            VStack(alignment: .leading, spacing: 0) {
                bulletRow(width: 58)
                bulletRow(width: 43)
                bulletRow(width: 58)
                bulletRow(width: 28)
                bulletRow(width: 58)
                bulletRow(width: 43)
                bulletRow(width: 58)
                bulletRow(width: 28)
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 10)
    }

    private func bulletRow(width: CGFloat) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(lineColor)
                .frame(width: 6, height: 6)
            RoundedRectangle(cornerRadius: 2)
                .fill(lineColor)
                .frame(width: width, height: 4)
        }
        .padding(.top, 5)
    }
}
