import AnytypeCore
import UIKit
import BlocksModels

struct MarkupStateCalculator {
    private let attributedText: NSAttributedString
    private let range: NSRange
    private let restrictions: BlockRestrictions
    private let alignment: NSTextAlignment?
    
    init(
        attributedText: NSAttributedString,
        range: NSRange,
        restrictions: BlockRestrictions,
        alignment: NSTextAlignment?
    ) {
        self.attributedText = attributedText
        self.range = range
        self.restrictions = restrictions
        self.alignment = alignment
    }
    
    func boldState() -> MarkupState {
        guard restrictions.canApplyBold else {
            return .disabled
        }
        return attributedText.isFontInWhole(range: range, has: .traitBold) ? .applied : .notApplied
    }
    
    func italicState() -> MarkupState {
        guard restrictions.canApplyItalic else {
            return .disabled
        }
        return attributedText.isFontInWhole(range: range, has: .traitItalic) ? .applied : .notApplied
    }
    
    func strikethroughState() -> MarkupState {
        guard restrictions.canApplyOtherMarkup else { return .disabled }
        guard attributedText.length > 0  else { return .notApplied }
        return attributedText.isEverySymbol(in: range, has: .strikethroughStyle) ? .applied : .notApplied
    }
    
    func codeState() -> MarkupState {
        guard restrictions.canApplyOtherMarkup else {
            return .disabled
        }
        return attributedText.isCodeFontInWhole(range: range) ? .applied : .notApplied
    }
    
    func linkState() -> MarkupState {
        guard restrictions.canApplyOtherMarkup else {
            return .disabled
        }
        let url: URL? = attributedText.value(for: .link, range: range)
        return url.isNil ? .notApplied : .applied
    }

    func alignmentState() -> [LayoutAlignment: MarkupState] {
        var alignmentState: [LayoutAlignment: MarkupState] = [:]

        LayoutAlignment.allCases.forEach { alignment in
            guard restrictions.availableAlignments.contains(alignment) else {
                alignmentState[alignment] = .disabled
                return
            }
            alignmentState[alignment] = .notApplied

            if alignment.asNSTextAlignment == self.alignment {
                alignmentState[alignment] = .applied
            }
        }
        return alignmentState
    }
    
    func state(for markup: TextAttributesType) -> MarkupState {
        switch markup {
        case .bold:
            return boldState()
        case .italic:
            return italicState()
        case .keyboard:
            return codeState()
        case .strikethrough:
            return strikethroughState()
        }
    }
}
