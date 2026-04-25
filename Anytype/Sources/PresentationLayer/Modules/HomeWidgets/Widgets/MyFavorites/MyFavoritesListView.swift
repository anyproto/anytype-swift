import Foundation
import SwiftUI

struct MyFavoritesListView: View {
    let model: MyFavoritesListViewModel

    @State private var favoritesDndState = DragState()

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(model.rows.enumerated()), id: \.element.id) { index, row in
                MyFavoritesRowView(
                    row: row,
                    showDivider: index != model.rows.count - 1,
                    spaceId: model.spaceId,
                    channelWidgetsObject: model.channelWidgetsObject,
                    personalWidgetsObject: model.personalWidgetsObject,
                    onObjectSelected: model.onObjectSelected
                )
                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 24, style: .continuous))
                .anytypeVerticalDrag(itemId: row.id)
                .setZeroOpacity(favoritesDndState.dragInitiateId == row.id && favoritesDndState.dragInProgress)
            }
        }
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .anytypeVerticalDrop(data: model.rows, state: $favoritesDndState) { from, to in
            model.dropUpdate(from: from, to: to)
        } dropFinish: { from, to in
            model.dropFinish(from: from, to: to)
        }
    }
}
