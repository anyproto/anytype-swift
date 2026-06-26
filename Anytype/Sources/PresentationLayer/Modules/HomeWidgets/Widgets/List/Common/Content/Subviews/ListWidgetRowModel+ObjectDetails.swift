import Foundation
import Services

extension ListWidgetRowModel {

    init(
        details: ObjectDetails,
        chatPreview: MessagePreviewModel? = nil,
        parentBadge: ParentObjectUnreadBadge? = nil,
        onTap: @escaping @MainActor (ScreenData) -> Void
    ) {
        let screenData = details.screenData()
        self = ListWidgetRowModel(
            objectId: details.id,
            icon: details.objectIconImage,
            title: details.pluralTitle,
            description: details.subtitle,
            chatPreview: chatPreview,
            parentBadge: parentBadge,
            screenData: screenData,
            onTap: {
                onTap(screenData)
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
            screenData: details.screenData,
            onTap: details.onItemTap
        )
    }
}
