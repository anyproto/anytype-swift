import Foundation
import BlocksModels

extension ListWidgetRow.Model {
    
    init(
        details: ObjectDetails,
        subtitle: String? = nil,
        isChecked: Bool = false,
        onTap: @escaping (EditorScreenData) -> Void,
        onCheckboxTap: (() -> Void)? = nil
    ) {
        self = ListWidgetRow.Model(
            objectId: details.id,
            icon: details.objectIconImage,
            title: details.title,
            description: details.subtitle,
            subtitle: subtitle,
            isChecked: isChecked,
            onTap: {
                let data = EditorScreenData(pageId: details.id, type: details.editorViewType)
                onTap(data)
            },
            onCheckboxTap: onCheckboxTap
        )
    }
}
