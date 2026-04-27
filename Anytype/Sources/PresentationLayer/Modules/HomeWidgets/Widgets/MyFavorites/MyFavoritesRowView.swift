import Foundation
import SwiftUI
import Services

struct MyFavoritesRowView: View {
    let row: MyFavoritesRowData
    let showDivider: Bool
    let spaceId: String
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol
    let onObjectSelected: (ObjectDetails) -> Void

    var body: some View {
        MyFavoritesRowInternalView(
            row: row,
            showDivider: showDivider,
            spaceId: spaceId,
            channelWidgetsObject: channelWidgetsObject,
            personalWidgetsObject: personalWidgetsObject,
            onObjectSelected: onObjectSelected
        )
        .id(row.id)
    }
}
