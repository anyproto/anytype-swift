import Foundation
import Services


struct WidgetObjectListRowModel: Identifiable {
    let objectId: String
    let icon: Icon
    let title: String
    let description: String?
    let subtitle: String?
    let isChecked: Bool
    let canArchive: Bool
    let menu: [WidgetObjectListMenuItemModel]
    let onTap: () -> Void
    let onCheckboxTap: (() -> Void)?
    
    var id: String { objectId }
}

extension WidgetObjectListRowModel {
    init(
        details: ObjectDetails,
        canArchive: Bool,
        isChecked: Bool = false,
        menu: [WidgetObjectListMenuItemModel] = [],
        onTap: @escaping () -> Void,
        onCheckboxTap: (() -> Void)? = nil
    ) {
        self.init(
            objectId: details.id,
            icon: details.objectIconImage,
            title: details.title,
            description: details.subtitle,
            subtitle: details.objectType.displayName,
            isChecked: isChecked,
            canArchive: canArchive,
            menu: menu,
            onTap: onTap,
            onCheckboxTap: onCheckboxTap
        )
    }
}
