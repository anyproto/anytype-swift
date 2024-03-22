import AnytypeCore
import Services
import Foundation

final class BlockMarkupChanger: BlockMarkupChangerProtocol {
    func toggleMarkup(
        _ attributedString: NSAttributedString,
        markup: MarkupType,
        contentType: BlockContentType
    ) -> NSAttributedString {

        let range = attributedString.wholeRange
        
        return toggleMarkup(attributedString, markup: markup, range: range, contentType: contentType)
    }
    
    func toggleMarkup(
        _ attributedString: NSAttributedString,
        markup: MarkupType,
        range: NSRange,
        contentType: BlockContentType
    ) -> NSAttributedString {
        let shouldApplyMarkup = !attributedString.hasMarkup(markup, range: range)

        return apply(
            markup,
            shouldApplyMarkup: shouldApplyMarkup,
            contentType: contentType,
            attributedString: attributedString,
            range: range
        )
    }

    func setMarkup(
        _ markup: MarkupType,
        range: NSRange,
        attributedString: NSAttributedString,
        contentType: BlockContentType
    ) -> NSAttributedString {
        updateMarkup(
            markup,
            shouldApplyMarkup: true,
            contentType: contentType,
            range: range,
            attributedString: attributedString
        )
    }

    func removeMarkup(
        _ markup: MarkupType,
        range: NSRange,
        contentType: BlockContentType,
        attributedString: NSAttributedString
    ) -> NSAttributedString {
        updateMarkup(
            markup,
            shouldApplyMarkup: false,
            contentType: contentType,
            range: range,
            attributedString: attributedString
        )
    }

    private func updateMarkup(
        _ markup: MarkupType,
        shouldApplyMarkup: Bool,
        contentType: BlockContentType,
        range: NSRange,
        attributedString: NSAttributedString
    ) -> NSAttributedString {
        apply(
            markup,
            shouldApplyMarkup: shouldApplyMarkup,
            contentType: contentType,
            attributedString: attributedString,
            range: range
        )
    }

    
    private func apply(
        _ action: MarkupType,
        shouldApplyMarkup: Bool,
        contentType: BlockContentType,
        attributedString: NSAttributedString,
        range: NSRange
    ) -> NSAttributedString {
        // Ignore changing markup in empty string
        guard range.length != 0 else { return attributedString }
        guard case let .text(style) = contentType else { return attributedString }
        
        
        let modifier = MarkStyleModifier(
            attributedString: attributedString,
            anytypeFont: style.uiFont
        )
        
        modifier.apply(action, shouldApplyMarkup: shouldApplyMarkup, range: range)

        switch action {
        case .link(let linkURL):
            if linkURL.isNotNil {
                modifier.apply(.linkToObject(nil), shouldApplyMarkup: true, range: range)
            }
        case .linkToObject(let blockId):
            if blockId.isNotNil {
                modifier.apply(.link(nil), shouldApplyMarkup: true, range: range)
            }
        default: break
        }

        return NSAttributedString(attributedString: modifier.attributedString)
    }
}
