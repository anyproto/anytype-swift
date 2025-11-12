import Foundation
import SwiftUI

struct ListWidgetCompactRow: View {
    
    let model: ListWidgetRowModel
    let showDivider: Bool
    
    @Environment(\.editMode) private var editMode

    private var titleColor: Color {
        model.chatPreview?.titleColor ?? .Text.primary
    }

    var body: some View {
        HStack(spacing: 12) {
            IconView(icon: model.icon)
                .frame(width: 18, height: 18)

            AnytypeText(model.title, style: .previewTitle2Medium)
                .foregroundColor(titleColor)
                .lineLimit(1)

            Spacer()

            if let chatPreview = model.chatPreview, chatPreview.hasCounters {
                HStack(spacing: 4) {
                    if chatPreview.mentionCounter > 0 {
                        MentionBadge(style: chatPreview.mentionStyle)
                    }
                    if chatPreview.unreadCounter > 0 {
                        CounterView(
                            count: chatPreview.unreadCounter,
                            style: chatPreview.unreadStyle
                        )
                    }
                }
            }
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
