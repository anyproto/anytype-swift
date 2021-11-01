enum SlashMenuCellData {
    case menu(type: SlashMenuItemType, actions: [SlashAction])
    case action(SlashAction)
    case header(title: String)
    
    static func menu(item: SlashMenuItem) -> SlashMenuCellData {
        .menu(type: item.type, actions: item.children)
    }
}
