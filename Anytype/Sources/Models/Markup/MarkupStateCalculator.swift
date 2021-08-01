import AnytypeCore
import Foundation

struct MarkupStateCalculator {
    
    private let attributedText: NSAttributedString
    private let range: NSRange
    private let restrictions: BlockRestrictions
    
    init(
        attributedText: NSAttributedString,
        range: NSRange,
        restrictions: BlockRestrictions
    ) {
        self.attributedText = attributedText
        self.range = range
        self.restrictions = restrictions
    }
    
    func boldState() -> MarkupState {
        guard restrictions.canApplyBold else {
            return .disabled
        }
        return attributedText.fontInWhole(range: range, has: .traitBold) ? .applied : .notApplied
    }
    
    func italicState() -> MarkupState {
        guard restrictions.canApplyItalic else {
            return .disabled
        }
        return attributedText.fontInWhole(range: range, has: .traitItalic) ? .applied : .notApplied
    }
    
    func strikethroughState() -> MarkupState {
        guard restrictions.canApplyOtherMarkup else { return .disabled }
        guard attributedText.length > 0  else { return .notApplied }
        return attributedText.everySymbol(in: range, has: .strikethroughStyle) ? .applied : .notApplied
    }
    
    func codeState() -> MarkupState {
        guard restrictions.canApplyOtherMarkup else {
            return .disabled
        }
        return attributedText.fontIsCodeInWhole(range: range) ? .applied : .notApplied
    }
}
