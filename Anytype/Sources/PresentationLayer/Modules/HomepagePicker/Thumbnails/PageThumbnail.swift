import SwiftUI

struct PageThumbnail: View {
    let isSelected: Bool

    private var lineColor: Color { isSelected ? Color.Control.accent50 : Color.Control.tertiary }
    private var headerBackground: Color { Color.Control.accent25 }
    private var textColor: Color { isSelected ? Color.Control.accent100 : Color.Text.secondary }

    var body: some View {
        // Header area with emoji (background only when selected)
        ZStack(alignment: .topLeading) {
            if isSelected {
                Rectangle()
                    .fill(headerBackground)
                    .frame(height: 40)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text("📄")
                    .font(.system(size: 20))
                // "Idea" title
                Text("Idea")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .padding(.top, 9)

                // Text lines block 1
                textBlock(lines: [68, 68, 68, 51], topPadding: 12)

                // Text lines block 2
                textBlock(lines: [68, 68, 68, 34], topPadding: 12)
            }
            .padding(.horizontal, 10)
            .padding(.top, 22)
            .padding(.bottom, 16)
        }
        .clipped()
        
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

#Preview {
    PageThumbnail(isSelected: false).frame(height: 172)
    PageThumbnail(isSelected: true).frame(height: 172)
}
