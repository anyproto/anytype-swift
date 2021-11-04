import BlocksModels

protocol BlockRestrictions {
    var canApplyBold: Bool { get }
    var canApplyItalic: Bool { get }
    var canApplyOtherMarkup: Bool { get }
    var canApplyBlockColor: Bool { get }
    var canApplyBackgroundColor: Bool { get }
    var canApplyMention: Bool { get }
    var turnIntoStyles: [BlockContentType] { get }
    var availableAlignments: [LayoutAlignment] { get }
    
    /// If block can create block below current on enter pressing
    var canCreateBlockBelowOnEnter: Bool { get }
}

extension BlockRestrictions {
    var canCreateBlockBelowOnEnter: Bool { true }
    
    func canApplyStyle(_ style: BlockContentType) -> Bool {
        turnIntoStyles.contains(style)
    }
    func canApplyTextStyle(_ style: BlockText.Style) -> Bool {
        turnIntoStyles.contains(.text(style))
    }
}
