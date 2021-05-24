
import BlocksModels

struct CodeBlockRestrictions: BlockRestrictions {
    
    var canApplyBold: Bool { false }
    var canApplyItalic: Bool { false }
    var canApplyOtherMarkup: Bool { false }
    var canApplyBlockColor: Bool { false }
    var canApplyBackgroundColor: Bool { false }
    var canApplyMention: Bool { false }
    var turnIntoStyles: [BlocksViews.Toolbar.BlocksTypes] {
        [.text(.text), .text(.h1), .text(.h2), .text(.h3), .text(.highlighted),
                .list(.checkbox), .list(.bulleted), .list(.numbered), .list(.toggle),
                .objects(.page)]
    }
    var availableAlignments: [BlockInformation.Alignment] {
        []
    }

    var canCreateBlockBelowOnEnter: Bool {
        false
    }
}
