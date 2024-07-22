import Foundation
import SwiftUI

struct ViewWidgetTabsItemModel {
    let dataviewId: String
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
}

struct ViewWidgetTabsItemView: View {
    
    let model: ViewWidgetTabsItemModel
    
    var body: some View {
        AnytypeText(model.title, style: .previewTitle2Medium)
            .foregroundColor(model.isSelected ? .Text.primary : .Widget.inactiveTab)
            .increaseTapGesture(EdgeInsets(horizontal: 8, vertical: 12)) {
                model.onTap()
            }
    }
}
