import Foundation
import SwiftUI
import Services

struct MyFavoritesRowView: View {
    let row: MyFavoritesViewModel.Row
    let showDivider: Bool
    let onTap: (ObjectDetails) -> Void

    var body: some View {
        Button {
            onTap(row.details)
        } label: {
            HStack(spacing: 12) {
                IconView(icon: row.details.objectIconImage)
                    .frame(width: 20, height: 20)

                AnytypeText(row.details.pluralTitle, style: .bodySemibold)
                    .foregroundStyle(Color.Text.primary)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .fixTappableArea()
        }
        .buttonStyle(.plain)
        .if(showDivider) {
            $0.newDivider(leadingPadding: 16, trailingPadding: 16, color: .Widget.divider)
        }
    }
}
