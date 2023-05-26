import Foundation

struct WidgetObjectListMenuItemModel: Identifiable {
    let id: String
    let title: String
    let negative: Bool
    let onTap: () -> Void
}
