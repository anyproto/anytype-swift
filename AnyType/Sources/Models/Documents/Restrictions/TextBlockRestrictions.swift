
import BlocksModels

struct TextBlockRestrictions: BlockRestrictions {
    
    var canApplyBold: Bool { true }
    var canApplyOtherMarkup: Bool { true }
    var canApplyBlockColor: Bool { true }
    var canApplyBackgroundColor: Bool { true }
    var canApplyMention: Bool { true }
    var turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes] {
        [.text(.text), .text(.h1), .text(.h2), .text(.h3), .text(.highlighted),
                .list(.checkbox), .list(.bulleted), .list(.numbered), .list(.toggle),
                .objects(.page),
                .other(.code)]
    }
    var availableAlignments: [BlockInformation.Alignment] {
        BlockInformation.Alignment.allCases
    }
}
