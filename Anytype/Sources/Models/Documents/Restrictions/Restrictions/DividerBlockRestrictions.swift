import BlocksModels

struct DividerBlockRestrictions: BlockRestrictions {
    
    let canApplyBold = false
    let canApplyItalic = false
    let canApplyOtherMarkup = false
    let canApplyBlockColor = false
    let canApplyBackgroundColor = true
    let canApplyMention = false
    let turnIntoStyles: [BlockViewType] = [.other(.lineDivider), .other(.dotsDivider)]
   
    let availableAlignments = [LayoutAlignment]()
}
