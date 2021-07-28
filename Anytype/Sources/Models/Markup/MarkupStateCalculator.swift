import BlocksModels

struct MarkupStateCalculator {
    
    private let content: BlockText
    private let alignment: LayoutAlignment
    private let restrictions: BlockRestrictions
    
    init(
        content: BlockText,
        alignment: LayoutAlignment,
        restrictions: BlockRestrictions
    ) {
        self.content = content
        self.alignment = alignment
        self.restrictions = restrictions
    }
    
    func textAttributes() -> TextAttributesViewController.AttributesState {
        TextAttributesViewController.AttributesState(
            bold: boldState(),
            italic: italicState(),
            strikethrough: strikethroughState(),
            codeStyle: codeState(),
            alignment: alignment.asNSTextAlignment,
            url: ""
        )
    }
    
    private func boldState() -> MarkupState {
        guard restrictions.canApplyBold else {
            return .disabled
        }
        return content.attributedText.wholeStringFontHasTrait(trait: .traitBold) ? .applied : .notApplied
    }
    
    private func italicState() -> MarkupState {
        guard restrictions.canApplyItalic else {
            return .disabled
        }
        return content.attributedText.wholeStringFontHasTrait(trait: .traitItalic) ? .applied : .notApplied
    }
    
    private func strikethroughState() -> MarkupState {
        guard restrictions.canApplyOtherMarkup else { return .disabled }
        guard content.attributedText.length > 0  else { return .notApplied }
        let range = NSRange(location: 0, length: content.attributedText.length)
        return content.attributedText.hasAttribute(.strikethroughStyle, at: range) ? .applied : .notApplied
    }
    
    private func codeState() -> MarkupState {
        guard restrictions.canApplyOtherMarkup else {
            return .disabled
        }
        return content.attributedText.wholeStringWithCodeMarkup() ? .applied : .notApplied
    }
}
