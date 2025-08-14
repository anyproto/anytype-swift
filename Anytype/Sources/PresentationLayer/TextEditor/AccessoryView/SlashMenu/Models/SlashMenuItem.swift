import Foundation

enum SlashMenuItem: Sendable {
    case single(action: SlashAction)
    case multi(type: SlashMenuItemType, children: [SlashAction])
    
    var children: [SlashAction] {
        switch self {
        case .single:
            return []
        case .multi(_, let children):
            return children
        }
    }
}
