import Foundation
import SwiftUI

struct RecentlyEditedListView: View {
    let model: RecentlyEditedListViewModel

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(model.rows.enumerated()), id: \.element.id) { index, row in
                RecentlyEditedRowView(
                    row: row,
                    showDivider: index != model.rows.count - 1,
                    onObjectSelected: model.onObjectSelected
                )
            }
        }
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
