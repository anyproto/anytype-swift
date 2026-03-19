@preconcurrency import ProtobufMessages

struct PageBlockRestrictions: BlockRestrictions {
    
    let canApplyBold = false
    let canApplyItalic = false
    let canApplyOtherMarkup = false
    let canApplyBlockColor = false
    let canApplyBackgroundColor = true
    let canApplyMention = false
    let canApplyEmoji = false
    let canDeleteOrDuplicate = true
    let turnIntoStyles: [BlockContentType] = [
        .text(.text), .text(.header), .text(.header2), .text(.header3), .text(.quote), .text(.code),
        .text(.checkbox), .text(.bulleted), .text(.numbered), .text(.toggle)
    ]
   
    let availableAlignments = LayoutAlignment.allCases
   
}
