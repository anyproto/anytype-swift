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

    private let chatPreviewBuilder: any WidgetChatPreviewBuilderProtocol = Container.shared.widgetChatPreviewBuilder()

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
        let previewsByChatId = Dictionary(chatPreviews.map { ($0.chatId, $0) }, uniquingKeysWith: { first, _ in first })
        return configs.map { config in
            let chatPreview = previewsByChatId[config.id].flatMap {
                chatPreviewBuilder.build(chatPreview: $0, spaceView: spaceView)
            }
            return ListWidgetRowModel(details: config, chatPreview: chatPreview)
        }
    }
}

extension Container {
    var widgetRowModelBuilder: Factory<any WidgetRowModelBuilderProtocol> {
        self { WidgetRowModelBuilder() }.shared
    }
}
