import Services

extension BlockRestrictions {
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
}
