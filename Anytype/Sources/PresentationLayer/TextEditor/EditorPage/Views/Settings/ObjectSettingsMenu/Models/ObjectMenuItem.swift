import Foundation

enum ObjectMenuItem: Identifiable {
    case setting(ObjectSetting)
    case action(ObjectAction)

    var id: String {
        switch self {
        case .setting(let setting):
            return "setting-\(setting.title)"
        case .action(let action):
            return "action-\(action.id)"
        }
    }

    var order: Int {
        switch self {
        case .setting(let setting):
            return setting.menuOrder
        case .action(let action):
            return action.menuOrder
        }
    }
}
