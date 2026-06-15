import UIKit

extension CursorModeAccessoryView {
    enum Item: CaseIterable, Hashable, Equatable {
        case slash
        case style
        case actions
        case mention
        case undoRedo
        case deleteBlock
        case indentRight
        case indentLeft

        var image: UIImage? {
            switch self {
            case .slash:
                return UIImage(asset: .X32.slashMenu)
            case .style:
                return UIImage(asset: .X32.style)
            case .mention:
                return UIImage(asset: .X32.mention)
            case .deleteBlock:
                return UIImage(asset: .X32.delete)
            case .indentLeft:
                return UIImage(asset: .X32.Insert.right)
            case .indentRight:
                return UIImage(asset: .X32.Insert.left)
            case .actions:
                return UIImage(asset: .X32.actions)
            case .undoRedo:
                return UIImage(asset: .X32.undoRedo)
            }
        }

        var action: CursorModeAccessoryViewAction {
            switch self {
            case .slash:
                return .slashMenu
            case .style:
                return .showStyleMenu
            case .mention:
                return .mention
            case .deleteBlock:
                return .deleteBlock
            case .indentLeft:
                return .indentLeft
            case .indentRight:
                return .indentRight
            case .actions:
                return .editingMode
            case .undoRedo:
                return .undoRedo
            }
        }
    }
}
