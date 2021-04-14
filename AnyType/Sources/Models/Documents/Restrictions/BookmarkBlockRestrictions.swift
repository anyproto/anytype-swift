
import BlocksModels

struct BookmarkBlockRestrictions: BlockRestrictions {
    
    var canApplyBold: Bool { false }
    var canApplyOtherMarkup: Bool { false }
    var canApplyBlockColor: Bool { false }
    var canApplyBackgroundColor: Bool { true }
    var canApplyMention: Bool { false }
    var turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes] {
        []
    }
    var availableAlignments: [BlockInformation.Alignment] {
        []
    }
}
