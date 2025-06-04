struct PropertyBlockRestrictions: BlockRestrictions {
    let canApplyBold = false
    let canApplyItalic = false
    let canApplyOtherMarkup = false
    let canApplyBlockColor = false
    let canApplyBackgroundColor = true
    let canApplyMention = false
    let canApplyEmoji = false
    let canDeleteOrDuplicate = true
    let availableAlignments: [LayoutAlignment] = []
    let turnIntoStyles: [BlockContentType] = []
}
