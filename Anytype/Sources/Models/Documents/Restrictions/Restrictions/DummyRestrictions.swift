import Services

struct DummyRestrictions: BlockRestrictions {
    let canApplyBold = false
    let canApplyItalic = false
    let canApplyOtherMarkup = false
    let canApplyBlockColor = false
    let canApplyBackgroundColor = false
    let canApplyMention = false
    let canApplyEmoji = false
    let canDeleteOrDuplicate = true
    let turnIntoStyles: [BlockContentType] = []
    let availableAlignments: [LayoutAlignment] = []
}
