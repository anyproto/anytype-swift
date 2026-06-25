import Foundation
import SwiftUI

struct ViewWidgetTabsItemModel: Equatable {
    let dataviewId: String
    let title: String
    let isSelected: Bool
    @EquatableNoop var onTap: () -> Void
}

struct ViewWidgetTabsItemView: View {
    
    let model: ViewWidgetTabsItemModel
    
    var body: some View {
        AnytypeText(model.title, style: .previewTitle2Medium)
            .foregroundStyle(model.isSelected ? Color.Text.primary : Color.Widget.inactiveTab)
            .increaseTapGesture(EdgeInsets(horizontal: 8, vertical: 12)) {
                model.onTap()
            }
    }
}
