import Foundation
import SwiftUI

struct UnreadItemsGroupedView: View {
    let items: [UnreadSectionRowData]
    let onTap: (UnreadSectionRowData) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let showDivider = index != items.count - 1
                UnreadRowView(data: item, showDivider: showDivider, onTap: onTap)
            }
        }
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
