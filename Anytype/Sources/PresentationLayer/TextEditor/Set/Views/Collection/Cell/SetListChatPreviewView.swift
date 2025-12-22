import SwiftUI

struct SetListChatPreviewView: View {
    let configuration: SetContentViewItemConfiguration
    let chatPreview: MessagePreviewModel

    var body: some View {
        HStack(spacing: 0) {
            if configuration.showIcon {
                IconView(icon: configuration.icon)
                    .frame(width: 48, height: 48)
                Spacer.fixedWidth(12)
            }

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 0) {
                    if configuration.showTitle {
                        AnytypeText(configuration.title, style: .previewTitle2Medium)
                            .foregroundStyle(chatPreview.titleColor)
                            .lineLimit(1)
                    }

                    Spacer()

                    AnytypeText(chatPreview.chatPreviewDate, style: .relation3Regular)
                        .foregroundStyle(Color.Text.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 0) {
                    AnytypeText(chatPreview.messagePreviewText, style: .relation2Regular)
                        .foregroundStyle(chatPreview.messagePreviewColor)
                        .lineLimit(1)

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
            }

            Spacer()
        }
        .background(Color.Background.primary)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.vertical, 20)
        .clipped()
        .fixTappableArea()
    }
}
