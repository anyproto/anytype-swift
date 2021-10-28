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
            return "Create Note".localized
        }
    }
    
    private var icon: UIApplicationShortcutIcon {
        switch self {
        case .newNote:
            return UIApplicationShortcutIcon(type: .add)
        }
    }
}
