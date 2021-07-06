
import BlocksModels

struct ListBlockRestrictions: BlockRestrictions {
    
    var canApplyBold: Bool { true }
    var canApplyItalic: Bool { true }
    var canApplyOtherMarkup: Bool { true }
    var canApplyBlockColor: Bool { true }
    var canApplyBackgroundColor: Bool { true }
    var canApplyMention: Bool { true }
    var turnIntoStyles: [BlockViewType] {
        [.text(.text), .text(.h1), .text(.h2), .text(.h3), .text(.highlighted),
                .list(.checkbox), .list(.bulleted), .list(.numbered), .list(.toggle),
                .objects(.page),
                .other(.code)]
    }
    var availableAlignments: [LayoutAlignment] {
        []
    }
}
