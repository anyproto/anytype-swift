import Foundation
import SwiftUI

struct SetWidgetHeaderItemModel {
    let dataviewId: String
    let title: String
    let onTap: () -> Void
    let isSelected: Bool
}

struct SetWidgetHeaderItem: View {
    
    let model: SetWidgetHeaderItemModel
    
    var body: some View {
        Button(action: {
            model.onTap()
        }, label: {
            AnytypeText(model.title, style: .previewTitle2Medium, color: model.isSelected ? .Text.primary : .Button.active)
        })
    }
}
