import Foundation
import SwiftUI

struct ListWidgetCompactRow: View {
    
    let model: ListWidgetRowModel
    
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = model.icon {
                SwiftUIObjectIconImageView(
                    iconImage: icon,
                    usecase: .widgetTree
                ).frame(width: 18, height: 18)
            }
            AnytypeText(model.title, style: .previewTitle2Medium, color: .Text.primary)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
        .fixTappableArea()
        .onTapGesture {
            model.onTap()
        }
        .newDivider(leadingPadding: 16, trailingPadding: 16)
    }
}
