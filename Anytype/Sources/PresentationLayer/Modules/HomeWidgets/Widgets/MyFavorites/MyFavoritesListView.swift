import Foundation
import SwiftUI
import Services

struct MyFavoritesListView: View {
    let rows: [MyFavoritesViewModel.Row]
    let accountInfo: AccountInfo
    /// Channel widgets document — threaded through so each row's long-press menu
    /// can render Pin-to-channel / Unpin-from-channel with up-to-date state.
    let channelWidgetsObject: any BaseDocumentProtocol
    let canManageChannelPins: Bool
    let onTapRow: (ObjectDetails) -> Void
    let dropUpdate: (_ from: DropDataElement<MyFavoritesViewModel.Row>, _ to: DropDataElement<MyFavoritesViewModel.Row>) -> Void
    let dropFinish: (_ from: DropDataElement<MyFavoritesViewModel.Row>, _ to: DropDataElement<MyFavoritesViewModel.Row>) -> Void

    @State private var favoritesDndState = DragState()

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                MyFavoritesRowView(
                    row: row,
                    showDivider: index != rows.count - 1,
                    accountInfo: accountInfo,
                    channelWidgetsObject: channelWidgetsObject,
                    canManageChannelPins: canManageChannelPins,
                    onTap: onTapRow
                )
                .setZeroOpacity(favoritesDndState.dragInitiateId == row.id)
                .anytypeVerticalDrag(itemId: row.id)
            }
        }
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 24, style: .continuous))
        .anytypeVerticalDrop(data: rows, state: $favoritesDndState) { from, to in
            dropUpdate(from, to)
        } dropFinish: { from, to in
            dropFinish(from, to)
        }
    }
}
