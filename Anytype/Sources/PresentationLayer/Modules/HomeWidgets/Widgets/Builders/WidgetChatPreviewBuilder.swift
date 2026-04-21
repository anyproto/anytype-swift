import Foundation
import Services

@MainActor
protocol WidgetChatPreviewBuilderProtocol: AnyObject, Sendable {
    func build(chatPreview: ChatMessagePreview, spaceView: SpaceView?) -> MessagePreviewModel?
}

@MainActor
final class WidgetChatPreviewBuilder: WidgetChatPreviewBuilderProtocol, Sendable {

    private let dateFormatter = ChatPreviewDateFormatter()

    func build(chatPreview: ChatMessagePreview, spaceView: SpaceView?) -> MessagePreviewModel? {
        guard let lastMessage = chatPreview.lastMessage else { return nil }

        let attachments = lastMessage.attachments.prefix(3).map { objectDetails in
            MessagePreviewModel.Attachment(
                id: objectDetails.id,
                icon: objectDetails.objectIconImage
            )
        }

        let notificationMode = spaceView?.effectiveNotificationMode(for: chatPreview.chatId) ?? .all

        return MessagePreviewModel(
            creatorTitle: lastMessage.creator?.title,
            text: lastMessage.text,
            attachments: Array(attachments),
            localizedAttachmentsText: lastMessage.localizedAttachmentsText,
            chatPreviewDate: dateFormatter.localizedDateString(for: lastMessage.createdAt, showTodayTime: true),
            unreadCounter: chatPreview.unreadCounter,
            mentionCounter: chatPreview.mentionCounter,
            hasUnreadReactions: chatPreview.hasUnreadReactions,
            notificationMode: notificationMode,
            chatName: nil
        )
    }
}
