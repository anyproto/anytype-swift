import SwiftUI

struct CollectionThumbnail: View {
    let isSelected: Bool

    private var lineColor: Color { isSelected ? Color.Control.accent50 : Color.Shape.tertiary }
    private var dotColor: Color { isSelected ? Color.Control.accent100 : Color.Shape.tertiary }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: "Tasks" + toggle
            HStack {
                // "Tasks" text placeholder
                RoundedRectangle(cornerRadius: 2)
                    .fill(lineColor)
                    .frame(width: 30, height: 8)
                Spacer()
                // Toggle circle
                Circle()
                    .fill(dotColor)
                    .frame(width: 10, height: 10)
            }
            .padding(.top, 14)

            // List rows
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<6, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(lineColor)
                        .frame(width: index % 2 == 0 ? 68 : 48, height: 4)
                }
            }
            .padding(.top, 12)

            Spacer()
        }
        .padding(.horizontal, 10)
    }
}
