import UIKit

extension CursorModeAccessoryView {
    enum Item: CaseIterable, Hashable, Equatable {
        case slash
        case style
        case actions
        case mention
        case undoRedo
        
        var image: UIImage? {
            switch self {
            case .mention:
                return UIImage(asset: .X32.mention)
            case .slash:
                return UIImage(asset: .X32.slashMenu)
            case .style:
                return UIImage(asset: .X32.style)
            case .actions:
                return UIImage(asset: .X32.actions)
            case .undoRedo:
                return UIImage(asset: .X32.undoRedo)
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
            case .undoRedo:
                return .undoRedo
            }
        }
    }
}
