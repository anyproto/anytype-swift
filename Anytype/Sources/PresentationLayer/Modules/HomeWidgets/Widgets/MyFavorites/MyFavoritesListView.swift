import Foundation
import SwiftUI

struct MyFavoritesListView: View {
    let model: MyFavoritesListViewModel

    @State private var favoritesDndState = DragState()
    @State private var rowWidths: [String: CGFloat] = [:]

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
                .readFrame { frame in
                    guard rowWidths[row.id] != frame.width else { return }
                    rowWidths[row.id] = frame.width
                }
                .anytypeVerticalDrag(itemId: row.id) {
                    // Keep the drag preview detached from the live row subtree. The live row owns
                    // subscriptions/context menu state, and iOS 26 can crash while rebuilding it
                    // for the cancel preview when the gesture is released near screen edges.
                    MyFavoritesDragPreviewView(
                        row: row,
                        width: rowWidths[row.id] ?? UIScreen.main.bounds.width - 40
                    )
                }
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

private struct MyFavoritesDragPreviewView: View {
    let row: MyFavoritesRowData
    let width: CGFloat

    var body: some View {
        HStack(spacing: 12) {
            IconView(icon: row.details.objectIconImage)
                .frame(width: 20, height: 20)

            AnytypeText(row.details.pluralTitle, style: .bodySemibold)
                .foregroundStyle(Color.Text.primary)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(width: width, height: 48)
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
