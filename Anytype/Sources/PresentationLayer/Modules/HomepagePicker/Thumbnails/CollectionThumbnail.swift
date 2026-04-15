import SwiftUI
import Loc

struct CollectionThumbnail: View {

    private var textColor: Color { Color.Control.secondary }
    private var lineColor: Color { Color.Control.tertiary }
    private var accentDot: Color { Color.Control.tertiary }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // "Tasks" title
            Text(Loc.HomepagePicker.Thumbnail.tasks)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(textColor)
                .lineLimit(1)

            // Subtitle line + toggle pill
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(lineColor)
                    .frame(width: 32, height: 4)
                Spacer()
                Capsule()
                    .fill(accentDot)
                    .frame(width: 20, height: 10)
            }

            // 8 bullet rows
            VStack(alignment: .leading, spacing: 6) {
                bulletRow(width: 58)
                bulletRow(width: 43)
                bulletRow(width: 58)
                bulletRow(width: 28)
                bulletRow(width: 58)
                bulletRow(width: 43)
                bulletRow(width: 58)
                bulletRow(width: 28)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 30)
        .padding(.bottom, 16)
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
    }
}

#Preview {
    CollectionThumbnail().frame(height: 172)
}
