import BlocksModels

protocol BlockRestrictions {
    var canApplyBold: Bool { get }
    var canApplyItalic: Bool { get }
    var canApplyOtherMarkup: Bool { get }
    var canApplyBlockColor: Bool { get }
    var canApplyBackgroundColor: Bool { get }
    var canApplyMention: Bool { get }
    var turnIntoStyles: [BlockViewType] { get }
    var availableAlignments: [LayoutAlignment] { get }
    
    /// If block can create block below current on enter pressing
    var canCreateBlockBelowOnEnter: Bool { get }
}

extension BlockRestrictions {
    var canCreateBlockBelowOnEnter: Bool { true }
}
