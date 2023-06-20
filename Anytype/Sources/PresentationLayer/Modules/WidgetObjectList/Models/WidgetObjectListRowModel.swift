import Foundation

struct WidgetObjectListRowModel: Identifiable {
    let objectId: String
    let icon: ObjectIconImage?
    let title: String
    let description: String?
    let subtitle: String?
    let isChecked: Bool
    let menu: [WidgetObjectListMenuItemModel]
    let onTap: () -> Void
    let onCheckboxTap: (() -> Void)?
    
    var id: String { objectId }
}
