import UIKit

extension CursorModeAccessoryView {
    enum Item {
        case mention
        case slash
        case style
        case actions

        var image: UIImage {
            switch self {
            case .mention:
                return UIImage.edititngToolbar.mention
            case .slash:
                return UIImage.edititngToolbar.addNew
            case .style:
                return UIImage.edititngToolbar.style
            case .actions:
                return UIImage.edititngToolbar.actions
            }
        }

        var action: CursorModeAccessoryViewAction {
            switch self {
            case .mention:
                return .mention
            case .slash:
                return .slashMenu
            case .style:
                return .showStyleMenu
            case .actions:
                return .editingMode
            }
        }
    }
}
