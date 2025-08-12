enum SlashMenuCellData {
    case menu(type: SlashMenuItemType, actions: [SlashAction])
    case action(SlashAction)
    case header(title: String)
    
    static func menu(item: SlashMenuItem) -> SlashMenuCellData {
        switch item {
        case .single(let action):
            return .action(action)
        case .multi(let type, let children):
            return .menu(type: type, actions: children)
        }
    }
}
