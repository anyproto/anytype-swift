import Foundation
import Services

extension ListWidgetRowModel {
    
    init(
        details: ObjectDetails,
        onTap: @escaping @MainActor (ScreenData) -> Void
    ) {
        self = ListWidgetRowModel(
            objectId: details.id,
            icon: details.objectIconImage,
            title: details.pluralTitle,
            description: details.subtitle,
            onTap: {
                onTap(details.screenData())
            }
        )
    }
    
    init(details: SetContentViewItemConfiguration) {
        self = ListWidgetRowModel(
            objectId: details.id,
            icon: details.icon,
            title: details.title,
            description: details.description,
            onTap: details.onItemTap
        )
    }
}
