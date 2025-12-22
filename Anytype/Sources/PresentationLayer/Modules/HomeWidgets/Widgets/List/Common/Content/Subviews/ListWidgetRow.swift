import Foundation
import SwiftUI

struct ListWidgetRow: View {
    
    let model: ListWidgetRowModel
    let showDivider: Bool
    
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        HStack(spacing: 0) {
            IconView(icon: model.icon)
                .frame(width: 48, height: 48)
            
            Spacer.fixedWidth(12)

            if let chatPreview = model.chatPreview {
                chatContent(chatPreview: chatPreview)
            } else {
                regularContent
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
            $0.newDivider(leadingPadding: 16, trailingPadding: 16, color: .Widget.divider)
        }
        .id(model.objectId)
    }

    @ViewBuilder
    private var regularContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            AnytypeText(model.title, style: .previewTitle2Medium)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
            if let description = model.description, description.isNotEmpty {
                Spacer.fixedHeight(1)
                AnytypeText(description, style: .relation3Regular)
                    .foregroundColor(.Widget.secondary)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private func chatContent(chatPreview: MessagePreviewModel) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 0) {
                AnytypeText(model.title, style: .previewTitle2Medium)
                    .foregroundColor(chatPreview.titleColor)
                    .lineLimit(1)

                Spacer()

                AnytypeText(chatPreview.chatPreviewDate, style: .relation3Regular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 0) {
                AnytypeText(chatPreview.messagePreviewText, style: .relation2Regular)
                    .foregroundColor(chatPreview.messagePreviewColor)
                    .lineLimit(1)

                Spacer()

                if chatPreview.hasCounters {
                    HStack(spacing: 4) {
                        if chatPreview.mentionCounter > 0 {
                            MentionBadge(style: chatPreview.mentionCounterStyle)
                        }
                        if chatPreview.unreadCounter > 0 {
                            CounterView(
                                count: chatPreview.unreadCounter,
                                style: chatPreview.unreadCounterStyle
                            )
                        }
                    }
                }
            }
        }
    }
}
