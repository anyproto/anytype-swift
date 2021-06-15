
import BlocksModels

struct DividerBlockRestrictions: BlockRestrictions {
    
    var canApplyBold: Bool { false }
    var canApplyItalic: Bool { false }
    var canApplyOtherMarkup: Bool { false }
    var canApplyBlockColor: Bool { false }
    var canApplyBackgroundColor: Bool { true }
    var canApplyMention: Bool { false }
    var turnIntoStyles: [BlockToolbarBlocksTypes] {
        [.other(.lineDivider), .other(.dotsDivider)]
    }
    var availableAlignments: [BlockInformationAlignment] {
        []
    }
}
