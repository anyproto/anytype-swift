import BlocksModels

struct ImageBlockRestrictions: BlockRestrictions {
    let canApplyBold = false
    let canApplyItalic = false
    let canApplyOtherMarkup = false
    let canApplyBlockColor = false
    let canApplyBackgroundColor = true
    let canApplyMention = false
    let turnIntoStyles = [BlockViewType]()
    let availableAlignments = LayoutAlignment.allCases
}
