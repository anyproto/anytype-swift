public protocol BlockRestrictions {
    var canApplyBold: Bool { get }
    var canApplyItalic: Bool { get }
    var canApplyOtherMarkup: Bool { get }
    var canApplyBlockColor: Bool { get }
    var canApplyBackgroundColor: Bool { get }
    var canApplyMention: Bool { get }
    var canApplyEmoji: Bool { get }
    var canDeleteOrDuplicate: Bool { get }
    var turnIntoStyles: [BlockContentType] { get }
    var availableAlignments: [LayoutAlignment] { get }
}

public extension BlockRestrictions {    
    func canApplyStyle(_ style: BlockContentType) -> Bool {
        turnIntoStyles.contains(style)
    }
    func canApplyTextStyle(_ style: BlockText.Style) -> Bool {
        turnIntoStyles.contains(.text(style))
    }

    func isAlignmentAvailable(_ alignment: LayoutAlignment) -> Bool {
        availableAlignments.contains { $0 == alignment }
    }
}
