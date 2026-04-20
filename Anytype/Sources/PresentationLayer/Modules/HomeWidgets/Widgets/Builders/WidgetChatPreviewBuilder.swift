import Foundation
import Services

@MainActor
protocol WidgetChatPreviewBuilderProtocol: AnyObject, Sendable {
    /// Builds the `MessagePreviewModel` for a single chat row. Returns `nil` when
    /// the object is not a chat or has no last message — callers should render a
    /// plain (non-chat) row in that case.
    func build(
        chatPreviews: [ChatMessagePreview],
        objectId: String,
        spaceView: SpaceView?
    ) -> MessagePreviewModel?
}

@MainActor
final class WidgetChatPreviewBuilder: WidgetChatPreviewBuilderProtocol, Sendable {

    private let dateFormatter = ChatPreviewDateFormatter()

    func build(
        chatPreviews: [ChatMessagePreview],
        objectId: String,
        spaceView: SpaceView?
    ) -> MessagePreviewModel? {
        guard let preview = chatPreviews.first(where: { $0.chatId == objectId }),
              let lastMessage = preview.lastMessage else {
            return nil
        }

        let attachments = lastMessage.attachments.prefix(3).map { objectDetails in
            MessagePreviewModel.Attachment(
                id: objectDetails.id,
                icon: objectDetails.objectIconImage
            )
        }

        let notificationMode = spaceView?.effectiveNotificationMode(for: objectId) ?? .all

        return MessagePreviewModel(
            creatorTitle: lastMessage.creator?.title,
            text: lastMessage.text,
            attachments: Array(attachments),
            localizedAttachmentsText: lastMessage.localizedAttachmentsText,
            chatPreviewDate: dateFormatter.localizedDateString(for: lastMessage.createdAt, showTodayTime: true),
            unreadCounter: preview.unreadCounter,
            mentionCounter: preview.mentionCounter,
            hasUnreadReactions: preview.hasUnreadReactions,
            notificationMode: notificationMode,
            chatName: nil
        )
    }
}
