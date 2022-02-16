import UIKit

enum AccessoryViewType: Equatable {
    case none
    case `default`(CursorModeAccessoryView)
    case changeType(ChangeTypeAccessoryView)
    case markup(MarkupAccessoryView)
    case mention(MentionView)
    case slashMenu(SlashMenuView)

    var view: UIView? {
        switch self {
        case .default(let view):
            return view
        case .markup(let view):
            return view
        case .changeType(let view):
            return view
        case .mention(let view):
            return view
        case .slashMenu(let view):
            return view
        case .none:
            return nil
        }
    }

    var animation: Bool {
        switch self {
        case .slashMenu, .mention:
            return true
        default:
            return false
        }
    }
}
