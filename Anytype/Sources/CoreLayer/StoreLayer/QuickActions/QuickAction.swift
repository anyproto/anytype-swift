import UIKit

enum QuickAction: String, CaseIterable {
    case newNote
    
    var shortcut: UIApplicationShortcutItem {
        UIApplicationShortcutItem(
            type: rawValue,
            localizedTitle: title,
            localizedSubtitle: nil,
            icon: icon
        )
    }
    
    private var title: String {
        switch self {
        case .newNote:
            // TODO: Fix
//            let defaultObjectName = ObjectTypeProvider.shared.defaultObjectType.name
//            return Loc.QuickAction.create("defaultObjectName")
            return ""
        }
    }
    
    private var icon: UIApplicationShortcutIcon {
        switch self {
        case .newNote:
            return UIApplicationShortcutIcon(type: .add)
        }
    }
}
