
import BlocksModels

struct DividerBlockRestrictions: BlockRestrictions {
    
    var canApplyBold: Bool { false }
    var canApplyItalic: Bool { false }
    var canApplyOtherMarkup: Bool { false }
    var canApplyBlockColor: Bool { false }
    var canApplyBackgroundColor: Bool { true }
    var canApplyMention: Bool { false }
    var turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes] {
        [.other(.lineDivider), .other(.dotsDivider)]
    }
    var availableAlignments: [BlockInformationAlignment] {
        []
    }
}
