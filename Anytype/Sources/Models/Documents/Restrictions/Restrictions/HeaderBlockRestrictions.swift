import BlocksModels

struct HeaderBlockRestrictions: BlockRestrictions {
    let canApplyBold = false
    let canApplyItalic = false
    let canApplyOtherMarkup = true
    let canApplyBlockColor = true
    let canApplyBackgroundColor = true
    let canApplyMention = true
    let availableAlignments = LayoutAlignment.allCases
    
    let turnIntoStyles: [BlockContentType] = [
        .text(.text), .text(.header), .text(.header2), .text(.header3), .text(.quote), .text(.code),
        .text(.checkbox), .text(.bulleted), .text(.numbered), .text(.toggle),
        .smartblock(.page)
    ]
}
