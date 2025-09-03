@preconcurrency import ProtobufMessages

struct TitleBlockRestrictions: BlockRestrictions {
    let canApplyBold = false
    let canApplyItalic = false
    let canApplyOtherMarkup = false
    let canApplyBlockColor = true
    let canApplyBackgroundColor = true
    let canApplyMention = true
    let canApplyEmoji = true
    let canDeleteOrDuplicate = false
    let availableAlignments: [LayoutAlignment] = []
    let turnIntoStyles: [BlockContentType] = []
}
