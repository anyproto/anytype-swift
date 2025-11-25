import Foundation
import Services
import Factory

@MainActor
protocol WidgetRowModelBuilderProtocol: AnyObject, Sendable {
    func buildListRows(
        from configs: [SetContentViewItemConfiguration],
        spaceView: SpaceView?,
        chatPreviews: [ChatMessagePreview]
    ) -> [ListWidgetRowModel]

    func buildGalleryRows(
        from configs: [SetContentViewItemConfiguration]
    ) -> [GalleryWidgetRowModel]
}

@MainActor
final class WidgetRowModelBuilder: WidgetRowModelBuilderProtocol, Sendable {

    private let dateFormatter = ChatPreviewDateFormatter()
    
    func buildGalleryRows(
        from configs: [SetContentViewItemConfiguration]
    ) -> [GalleryWidgetRowModel] {
        configs.map { GalleryWidgetRowModel(details: $0) }
    }

    func buildListRows(
        from configs: [SetContentViewItemConfiguration],
        spaceView: SpaceView?,
        chatPreviews: [ChatMessagePreview]
    ) -> [ListWidgetRowModel] {
        configs.map { config in
            let chatPreview = buildChatPreview(
                objectId: config.id,
                spaceView: spaceView,
                chatPreviews: chatPreviews
            )
            return ListWidgetRowModel(details: config, chatPreview: chatPreview)
        }
    }

    private func buildChatPreview(
        objectId: String,
        spaceView: SpaceView?,
        chatPreviews: [ChatMessagePreview]
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

        let isMuted = !(spaceView?.effectiveNotificationMode(for: objectId).isUnmutedAll ?? true)

        return MessagePreviewModel(
            creatorTitle: lastMessage.creator?.title,
            text: lastMessage.text,
            attachments: Array(attachments),
            localizedAttachmentsText: lastMessage.localizedAttachmentsText,
            chatPreviewDate: dateFormatter.localizedDateString(for: lastMessage.createdAt, showTodayTime: true),
            unreadCounter: preview.unreadCounter,
            mentionCounter: preview.mentionCounter,
            isMuted: isMuted,
            chatName: nil
        )
    }
}

extension Container {
    var widgetRowModelBuilder: Factory<any WidgetRowModelBuilderProtocol> {
        self { WidgetRowModelBuilder() }.shared
    }
}
