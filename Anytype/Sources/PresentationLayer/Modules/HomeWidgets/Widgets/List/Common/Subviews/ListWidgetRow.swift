import Foundation
import SwiftUI

struct ListWidgetRow: View {
    
    let model: ListWidgetRowModel
    let showDivider: Bool
    
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = model.icon {
                SwiftUIObjectIconImageView(
                    iconImage: icon,
                    usecase: .widgetList
                ).frame(width: 48, height: 48)
            }
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(model.title, style: .previewTitle2Medium, color: .Text.primary)
                    .lineLimit(1)
                if let description = model.description, description.isNotEmpty {
                    Spacer.fixedHeight(1)
                    AnytypeText(description, style: .relation3Regular, color: .Text.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 72)
        .fixTappableArea()
        .onTapGesture {
            model.onTap()
        }
        .if(showDivider) {
            $0.newDivider(leadingPadding: 16, trailingPadding: 16)
        }
    }
}
