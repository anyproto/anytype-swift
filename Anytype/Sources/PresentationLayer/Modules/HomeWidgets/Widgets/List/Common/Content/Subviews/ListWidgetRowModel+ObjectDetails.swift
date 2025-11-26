import Foundation
import Services

extension ListWidgetRowModel {
    
    init(
        details: ObjectDetails,
        chatPreview: MessagePreviewModel? = nil,
        onTap: @escaping @MainActor (ScreenData) -> Void
    ) {
        self = ListWidgetRowModel(
            objectId: details.id,
            icon: details.objectIconImage,
            title: details.pluralTitle,
            description: details.subtitle,
            chatPreview: chatPreview,
            onTap: {
                onTap(details.screenData())
            }
        )
    }

    init(details: SetContentViewItemConfiguration, chatPreview: MessagePreviewModel? = nil) {
        self = ListWidgetRowModel(
            objectId: details.id,
            icon: details.icon,
            title: details.title,
            description: details.description,
            chatPreview: chatPreview,
            onTap: details.onItemTap
        )
    }
}
