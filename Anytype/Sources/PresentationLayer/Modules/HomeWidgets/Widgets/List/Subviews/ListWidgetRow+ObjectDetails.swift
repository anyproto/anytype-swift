import Foundation
import BlocksModels

extension ListWidgetRow.Model {
    
    init(details: ObjectDetails, showType = false, onTap: @escaping (EditorScreenData) -> Void) {
        self = ListWidgetRow.Model(
            objectId: details.id,
            icon: details.objectIconImage,
            title: details.title,
            description: details.subtitle,
            type: showType ? details.objectType.name : nil,
            onTap: {
                let data = EditorScreenData(pageId: details.id, type: details.editorViewType)
                onTap(data)
            }
        )
    }
}
