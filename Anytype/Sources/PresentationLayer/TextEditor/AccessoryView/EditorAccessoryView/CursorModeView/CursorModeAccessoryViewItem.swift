import UIKit

extension CursorModeAccessoryView {
    enum Item {
        case mention
        case slash
        case style
        case actions

        var image: UIImage? {
            switch self {
            case .mention:
                return UIImage(asset: .EditingToolbar.mention)
            case .slash:
                return UIImage(asset: .EditingToolbar.addNew)
            case .style:
                return UIImage(asset: .EditingToolbar.style)
            case .actions:
                return UIImage(asset: .EditingToolbar.actions)
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
