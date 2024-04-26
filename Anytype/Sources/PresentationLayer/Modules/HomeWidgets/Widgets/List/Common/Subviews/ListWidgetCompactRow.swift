import Foundation
import SwiftUI

struct ListWidgetCompactRow: View {
    
    let model: ListWidgetRowModel
    let showDivider: Bool
    
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = model.icon {
                IconView(icon: icon)
                    .frame(width: 18, height: 18)
                    .onTapGesture {
                        model.onIconTap()
                    }
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
        .if(showDivider) {
            $0.newDivider(leadingPadding: 16, trailingPadding: 16, color: .Widget.divider)
        }
    }
}
