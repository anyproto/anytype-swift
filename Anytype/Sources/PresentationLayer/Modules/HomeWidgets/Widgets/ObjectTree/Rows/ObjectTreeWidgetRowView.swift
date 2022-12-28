import Foundation
import SwiftUI

struct ObjectTreeWidgetRowViewModel {
    
    enum ExpandedType {
        case set
        case arrow(expanded: Bool)
        case dot
    }
    
    let id: String
    let title: String
    let expandedType: ExpandedType
    let level: Int
}

struct ObjectTreeWidgetRowView: View {
    
    let model: ObjectTreeWidgetRowViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer.fixedWidth(16)
            Image(asset: .Widget.collapse)
                .frame(width: 20, height: 20)
            Spacer.fixedWidth(8)
            // TODO: For image
//            Image()
//                .frame(width: 18, height: 18)
//            Spacer.fixedWidth(12)
            AnytypeText(model.title, style: .previewTitle2Medium, color: .Text.primary)
                .lineLimit(1)
            Spacer.fixedWidth(12)
            Spacer()
        }
        .frame(height: 40)
        .newDivider(leadingPadding: 16, trailingPadding: 16)
    }
}
