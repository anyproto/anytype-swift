
import BlocksModels

struct PageBlockRestrictions: BlockRestrictions {
    
    var canApplyBold: Bool { false }
    var canApplyItalic: Bool { false }
    var canApplyOtherMarkup: Bool { false }
    var canApplyBlockColor: Bool { false }
    var canApplyBackgroundColor: Bool { true }
    var canApplyMention: Bool { false }
    var turnIntoStyles: [BlockToolbar.BlocksTypes] {
        [.text(.text), .text(.h1), .text(.h2), .text(.h3), .text(.highlighted),
         .list(.checkbox), .list(.bulleted), .list(.numbered), .list(.toggle),
         .objects(.page)]
    }
    var availableAlignments: [BlockInformationAlignment] {
        BlockInformationAlignment.allCases
    }
}
