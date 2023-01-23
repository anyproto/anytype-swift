import Foundation
import BlocksModels

extension ListWidgetRow.Model {
    
    init(details: ObjectDetails, onTap: @escaping (EditorScreenData) -> Void) {
        self = ListWidgetRow.Model(
            objectId: details.id,
            icon: details.objectIconImage,
            title: details.title,
            description: details.description,
            onTap: {
                let data = EditorScreenData(pageId: details.id, type: details.editorViewType)
                onTap(data)
            }
        )
    }
}
