import Services

struct SimpleTableTextCellRestrictions: BlockRestrictions {
    let canApplyBold = true
    let canApplyItalic = true
    let canApplyOtherMarkup = true
    let canApplyBlockColor = true
    let canApplyBackgroundColor = true
    let canApplyMention = true
    let canApplyEmoji = true
    let canDeleteOrDuplicate = false
    let availableAlignments = LayoutAlignment.allCases

    let turnIntoStyles: [BlockContentType] = [.text(.text)]
}
