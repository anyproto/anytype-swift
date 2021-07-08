import BlocksModels

struct TextBlockRestrictions: BlockRestrictions {
    
    let canApplyBold = true
    let canApplyItalic = true
    let canApplyOtherMarkup = true
    let canApplyBlockColor = true
    let canApplyBackgroundColor = true
    let canApplyMention = true
    let availableAlignments = LayoutAlignment.allCases
    
    let turnIntoStyles: [BlockViewType] = [
        .text(.text), .text(.h1), .text(.h2), .text(.h3), .text(.highlighted),
        .list(.checkbox), .list(.bulleted), .list(.numbered), .list(.toggle),
        .objects(.page), .other(.code)
    ]
}
