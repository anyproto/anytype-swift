import BlocksModels

struct CodeBlockRestrictions: BlockRestrictions {
    
    let canApplyBold = false
    let canApplyItalic = false
    let canApplyOtherMarkup = false
    let canApplyBlockColor = false
    let canApplyBackgroundColor = true
    let canApplyMention = false
    
    let turnIntoStyles: [BlockViewType] = [
        .text(.text), .text(.h1), .text(.h2), .text(.h3), .text(.highlighted),
        .list(.checkbox), .list(.bulleted), .list(.numbered), .list(.toggle),
        .objects(.page)
    ]
    let availableAlignments = [LayoutAlignment]()

    let canCreateBlockBelowOnEnter = false
}
