import Foundation
import Services

extension ListWidgetRowModel {
    
    init(
        details: ObjectDetails,
        onTap: @escaping @Sendable @MainActor (EditorScreenData) -> Void
    ) {
        self = ListWidgetRowModel(
            objectId: details.id,
            icon: details.objectIconImage,
            title: details.title,
            description: details.subtitle,
            onTap: {
                onTap(details.editorScreenData())
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
