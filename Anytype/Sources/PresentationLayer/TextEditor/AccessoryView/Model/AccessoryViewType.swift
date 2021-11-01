import UIKit

enum AccessoryViewType: Equatable {
    case none
    case `default`(EditorAccessoryView)
    case changeType(ChangeTypeAccessoryView)
    case mention(MentionView)
    case slashMenu(SlashMenuView)
    case urlInput(URLInputAccessoryView)

    var view: UIView? {
        switch self {
        case .default(let view):
            return view
        case .changeType(let view):
            return view
        case .mention(let view):
            return view
        case .slashMenu(let view):
            return view
        case .urlInput(let view):
            return view
        case .none:
            return nil
        }
    }
}
