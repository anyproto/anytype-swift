import Foundation
import SwiftUI
import Services

struct MyFavoritesListView: View {
    let rows: [MyFavoritesViewModel.Row]
    let onTapRow: (ObjectDetails) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                MyFavoritesRowView(
                    row: row,
                    showDivider: index != rows.count - 1,
                    onTap: onTapRow
                )
            }
        }
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
