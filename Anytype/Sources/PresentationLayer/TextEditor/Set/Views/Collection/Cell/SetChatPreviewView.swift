import SwiftUI

struct SetChatPreviewView: View {
    let configuration: SetContentViewItemConfiguration
    let chatPreview: MessagePreviewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                if configuration.showIcon {
                    IconView(icon: configuration.icon)
                        .frame(width: 32, height: 32)
                }

                if configuration.showTitle {
                    AnytypeText(configuration.title, style: .previewTitle2Medium)
                        .foregroundColor(chatPreview.titleColor)
                        .lineLimit(1)
                }

                Spacer()

                if chatPreview.hasCounters {
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

            HStack(spacing: 0) {
                AnytypeText(chatPreview.messagePreviewText, style: .relation2Regular)
                    .foregroundColor(chatPreview.messagePreviewColor)
                    .lineLimit(2)

                Spacer()
            }

            HStack(spacing: 0) {
                AnytypeText(chatPreview.chatPreviewDate, style: .relation3Regular)
                    .foregroundColor(.Text.secondary)
                    .lineLimit(1)

                Spacer()
            }
        }
    }
}
