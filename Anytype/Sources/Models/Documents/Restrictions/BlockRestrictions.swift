import Services

protocol BlockRestrictions {
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

extension BlockRestrictions {    
    func canApplyStyle(_ style: BlockContentType) -> Bool {
        turnIntoStyles.contains(style)
    }
    func canApplyTextStyle(_ style: BlockText.Style) -> Bool {
        turnIntoStyles.contains(.text(style))
    }

    func isMarkupAvailable(_ markup: MarkupType) -> Bool {
        switch markup {
        case .bold:
            return canApplyBold
        case .italic:
            return canApplyItalic
        case .keyboard:
            return canApplyOtherMarkup
        case .strikethrough:
            return canApplyOtherMarkup
        case .underscored:
            return canApplyOtherMarkup
        case .textColor:
            return canApplyOtherMarkup
        case .backgroundColor:
            return canApplyBackgroundColor
        case .link:
            return canApplyOtherMarkup
        case .linkToObject:
            return canApplyOtherMarkup
        case .mention:
            return canApplyOtherMarkup
        case .emoji:
            return canApplyEmoji
        }
    }

    func isAlignmentAvailable(_ alignment: LayoutAlignment) -> Bool {
        availableAlignments.contains { $0 == alignment }
    }
}
