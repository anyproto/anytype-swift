import SwiftUI

struct PageThumbnail: View {
    let isSelected: Bool

    private var lineColor: Color { isSelected ? Color.Control.accent50 : Color.Shape.tertiary }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Document icon placeholder
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(lineColor)
                .frame(width: 24, height: 24)
                .padding(.top, 24)

            // "Idea" title
            RoundedRectangle(cornerRadius: 2)
                .fill(lineColor)
                .frame(width: 28, height: 11)
                .padding(.top, 9)

            // Text lines block 1
            textBlock(lines: [68, 68, 68, 51], topPadding: 12)

            // Text lines block 2
            textBlock(lines: [68, 68, 68, 34], topPadding: 8)
        }
        .padding(.horizontal, 10)
    }

    private func textBlock(lines: [CGFloat], topPadding: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, width in
                RoundedRectangle(cornerRadius: 2)
                    .fill(lineColor)
                    .frame(width: width, height: 4)
            }
        }
        .padding(.top, topPadding)
    }
}
