import Foundation
import Services

extension ListWidgetRowModel {

    init(
        details: ObjectDetails,
        chatPreview: MessagePreviewModel? = nil,
        parentBadge: ParentObjectUnreadBadge? = nil,
        onTap: @escaping @MainActor (ScreenData) -> Void
    ) {
        self = ListWidgetRowModel(
            objectId: details.id,
            icon: details.objectIconImage,
            title: details.pluralTitle,
            description: details.subtitle,
            chatPreview: chatPreview,
            parentBadge: parentBadge,
            onTap: {
                onTap(details.screenData())
            }
        )
    }

    init(
        details: SetContentViewItemConfiguration,
        chatPreview: MessagePreviewModel? = nil,
        parentBadge: ParentObjectUnreadBadge? = nil
    ) {
        self = ListWidgetRowModel(
            objectId: details.id,
            icon: details.icon,
            title: details.title,
            description: details.description,
            chatPreview: chatPreview,
            parentBadge: parentBadge,
            onTap: details.onItemTap
        )
    }
}
