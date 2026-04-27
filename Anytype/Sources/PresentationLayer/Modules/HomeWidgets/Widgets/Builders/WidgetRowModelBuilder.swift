import Foundation
import Services
import Factory

@MainActor
protocol WidgetRowModelBuilderProtocol: AnyObject, Sendable {
    func buildListRows(
        from configs: [SetContentViewItemConfiguration],
        spaceView: SpaceView?,
        chatPreviews: [ChatMessagePreview],
        unreadParents: [DiscussionUnreadParent]
    ) -> [ListWidgetRowModel]

    func buildGalleryRows(
        from configs: [SetContentViewItemConfiguration]
    ) -> [GalleryWidgetRowModel]
}

@MainActor
final class WidgetRowModelBuilder: WidgetRowModelBuilderProtocol, Sendable {

    private let chatPreviewBuilder: any WidgetChatPreviewBuilderProtocol = Container.shared.widgetChatPreviewBuilder()
    private let parentBadgeBuilder: any ParentObjectUnreadBadgeBuilderProtocol = Container.shared.parentObjectUnreadBadgeBuilder()

    func buildGalleryRows(
        from configs: [SetContentViewItemConfiguration]
    ) -> [GalleryWidgetRowModel] {
        configs.map { GalleryWidgetRowModel(details: $0) }
    }

    func buildListRows(
        from configs: [SetContentViewItemConfiguration],
        spaceView: SpaceView?,
        chatPreviews: [ChatMessagePreview],
        unreadParents: [DiscussionUnreadParent]
    ) -> [ListWidgetRowModel] {
        let previewsByChatId = Dictionary(
            chatPreviews.lazy.map { ($0.chatId, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        let unreadParentsById = Dictionary(
            unreadParents.lazy.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        return configs.map { config in
            if let chatPreview = previewsByChatId[config.id].flatMap({
                chatPreviewBuilder.build(chatPreview: $0, spaceView: spaceView)
            }) {
                return ListWidgetRowModel(details: config, chatPreview: chatPreview)
            }
            if let parent = unreadParentsById[config.id] {
                let parentBadge = parentBadgeBuilder.build(parent: parent, spaceView: spaceView)
                return ListWidgetRowModel(details: config, parentBadge: parentBadge)
            }
            return ListWidgetRowModel(details: config)
        }
    }
}

extension Container {
    var widgetRowModelBuilder: Factory<any WidgetRowModelBuilderProtocol> {
        self { WidgetRowModelBuilder() }.shared
    }
}
