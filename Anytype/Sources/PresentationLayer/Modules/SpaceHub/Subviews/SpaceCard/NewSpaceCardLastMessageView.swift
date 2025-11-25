import SwiftUI
import Services

struct NewSpaceCardLastMessageView: View {

    let model: MessagePreviewModel
    let supportsMultiChats: Bool

    var body: some View {
        Group {
            if model.attachments.isNotEmpty {
                messageWithAttachements
            } else if model.text.isNotEmpty {
                messageWithoutAttachements
            } else {
                AnytypeText(model.creatorTitle ?? Loc.Chat.newMessages, style: .chatPreviewRegular)
                    .foregroundColor(.Text.transparentSecondary)
                    .lineLimit(1)
            }
        }
        .multilineTextAlignment(.leading)
    }
    
    private var messageWithoutAttachements: some View {
        Group {
            if supportsMultiChats, let chatName = model.chatName {
                multiChatMessageView(chatName: chatName, messageText: model.text, creatorTitle: model.creatorTitle)
            } else if let creatorTitle = model.creatorTitle {
                AnytypeText("\(creatorTitle): \(model.text)", style: .chatPreviewRegular)
                    .foregroundColor(.Text.transparentSecondary)
                    .lineLimit(2)
            } else {
                AnytypeText(model.text, style: .chatPreviewRegular)
                    .foregroundColor(.Text.transparentSecondary)
                    .lineLimit(2)
            }
        }
        .anytypeLineHeightStyle(.chatPreviewRegular)
    }

    private func multiChatMessageView(chatName: String, messageText: String, creatorTitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            AnytypeText(chatName, style: .chatPreviewMedium)
                .foregroundColor(.Text.transparentSecondary)
                .lineLimit(1)
            if let creatorTitle {
                AnytypeText("\(creatorTitle): \(messageText)", style: .chatPreviewRegular)
                    .foregroundColor(.Text.transparentSecondary)
                    .lineLimit(1)
            } else {
                AnytypeText(messageText, style: .chatPreviewRegular)
                    .foregroundColor(.Text.transparentSecondary)
                    .lineLimit(1)
            }
        }
    }

    private var messageWithAttachements: some View {
        VStack(alignment: .leading, spacing: 2) {
            if supportsMultiChats {
                if let chatName = model.chatName {
                    AnytypeText(chatName, style: .chatPreviewMedium)
                        .foregroundColor(.Text.transparentSecondary)
                        .lineLimit(1)
                }
            } else if let creatorTitle = model.creatorTitle {
                AnytypeText(creatorTitle, style: .chatPreviewRegular)
                    .foregroundColor(.Text.transparentSecondary)
                    .lineLimit(1)
            }

            HStack(spacing: 2) {
                if supportsMultiChats, let creatorTitle = model.creatorTitle {
                    AnytypeText("\(creatorTitle):", style: .chatPreviewRegular)
                        .foregroundColor(.Text.transparentSecondary)
                        .lineLimit(1)
                }
                Spacer.fixedWidth(2)
                
                ForEach(model.attachments) {
                    IconView(icon: $0.icon).frame(width: 18, height: 18)
                }

                Spacer.fixedWidth(2)
                AnytypeText(model.localizedAttachmentsText, style: .chatPreviewRegular)
                    .foregroundColor(.Text.transparentSecondary)
                    .lineLimit(1)
            }
        }
    }
}
