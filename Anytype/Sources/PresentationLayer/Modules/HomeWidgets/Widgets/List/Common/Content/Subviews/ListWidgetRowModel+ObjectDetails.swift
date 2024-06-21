import Foundation
import Services

extension ListWidgetRowModel {
    
    init(
        details: ObjectDetails,
        onTap: @escaping (EditorScreenData) -> Void
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
}
