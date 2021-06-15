
import BlocksModels

struct HeaderBlockRestrictions: BlockRestrictions {
    
    var canApplyBold: Bool { false }
    var canApplyItalic: Bool { false }
    var canApplyOtherMarkup: Bool { true }
    var canApplyBlockColor: Bool { true }
    var canApplyBackgroundColor: Bool { true }
    var canApplyMention: Bool { true }
    var turnIntoStyles: [BlockToolbar.BlocksTypes] {
        [.text(.text), .text(.h1), .text(.h2), .text(.h3), .text(.highlighted),
                .list(.checkbox), .list(.bulleted), .list(.numbered), .list(.toggle),
                .objects(.page),
                .other(.code)]
    }
    var availableAlignments: [BlockInformationAlignment] {
        BlockInformationAlignment.allCases
    }
}
