struct SlashMenuFilteredItem {
    let title: String
    let topMatch: SlashMenuItemFilterMatch
    let actions: [SlashAction]
}

struct SlashActionFilterMatch {
    let action: SlashAction
    let filterMatch: SlashMenuItemFilterMatch
}
