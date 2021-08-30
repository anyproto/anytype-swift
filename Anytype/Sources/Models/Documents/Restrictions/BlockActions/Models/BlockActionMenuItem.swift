
import Foundation

enum BlockActionMenuItem {
    case menu(item: SlashMenuItemType, children: [BlockActionMenuItem])
    case action(BlockActionType)
    case sectionDivider(String)
    
    func actions() -> [BlockActionType] {
        switch self {
        case .sectionDivider:
            return []
        case let .action(action):
            return [action]
        case let .menu(_, items):
            return items.flatMap { $0.actions() }
        }
    }
}
