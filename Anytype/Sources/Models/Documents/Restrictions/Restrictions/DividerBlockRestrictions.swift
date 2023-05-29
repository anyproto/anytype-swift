import BlocksModels

struct DividerBlockRestrictions: BlockRestrictions {
    
    let canApplyBold = false
    let canApplyItalic = false
    let canApplyOtherMarkup = false
    let canApplyBlockColor = false
    let canApplyBackgroundColor = true
    let canApplyMention = false
    let canDeleteOrDuplicate = true
    let canApplyEmoji = false
    let turnIntoStyles: [BlockContentType] = [.divider(.line), .divider(.dots)]
   
    let availableAlignments = [LayoutAlignment]()
}
