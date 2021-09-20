enum SlashMenuCellData {
    case menu(item: SlashMenuItemType, actions: [SlashAction])
    case action(SlashAction)
    case header(title: String)
}
