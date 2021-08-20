import AnytypeCore
import UIKit

final class MarkStyleModifier {
    
    let attributedString: NSMutableAttributedString
    private let defaultNonCodeFont: UIFont
    
    init(
        attributedText: NSMutableAttributedString = .init(),
        defaultNonCodeFont: UIFont
    ) {
        attributedString = attributedText
        self.defaultNonCodeFont = defaultNonCodeFont
    }
    
    private func getAttributes(at range: NSRange) -> [NSAttributedString.Key : Any] {
        switch (attributedString.string.isEmpty, range) {
        // isEmpty & range == zero(0, 0) - assuming that we deleted text. So, we need to apply default typing attributes that are coming from textView.
        case (true, NSRange(location: 0, length: 0)): return [:]
            
        // isEmpty & range != zero(0, 0) - strange situation, we can't do that. Error, we guess. In that case we need only empty attributes.
        case (true, _): return [:]
        
        // At the end.
        case let (_, value) where value.location == attributedString.length && value.length == 0: return [:]
            
        // Otherwise, return string attributes.
        default: break
        }
        guard attributedString.length >= range.location + range.length else { return [:] }
        return attributedString.attributes(at: range.lowerBound, longestEffectiveRange: nil, in: range)
    }
    
    private func mergeAttributes(origin: [NSAttributedString.Key : Any], changes: [NSAttributedString.Key : Any]) -> [NSAttributedString.Key : Any] {
        var result = origin
        result.merge(changes) { (source, target) in target }
        return result
    }
    
    func apply(_ action: MarkStyleAction, range: NSRange) {
        guard range.location >= 0, attributedString.length >= range.length else {
            anytypeAssertionFailure("Range out of bounds in \(#function)")
            return
        }
        switch action {
        case .bold,
             .italic,
             .keyboard,
             .backgroundColor,
             .textColor,
             .link,
             .underscored,
             .strikethrough:
            apply(action, toAllSubrangesIn: range)
        case .mention:
            apply(action, toWhole: range)
        }
    }
    
    private func apply(_ action: MarkStyleAction, toWhole range: NSRange) {
        let oldAttributes = getAttributes(at: range)
        guard let update = apply(action, to: oldAttributes) else { return }
        
        var newAttributes = mergeAttributes(
            origin: oldAttributes,
            changes: update.changeAttributes
        )
        for key in update.deletedKeys {
            newAttributes.removeValue(forKey: key)
            attributedString.removeAttribute(key, range: range)
        }

        attributedString.addAttributes(newAttributes, range: range)
        if case let .mention(id) = action, let pageId = id {
            applyMention(pageId: pageId, range: range)
        }
    }
    
    private func apply(_ action: MarkStyleAction, toAllSubrangesIn range: NSRange) {
        attributedString.enumerateAttributes(in: range) { _, subrange, _ in
            apply(action, toWhole: subrange)
        }
    }
    
    private func applyMention(pageId: String, range: NSRange) {
        // This attachment is for displaying icon in front of mention: 🦊Fox
        let mentionAttributedString = attributedString.attributedSubstring(from: range)
        let mentionAttachment = MentionAttachment(
            name: mentionAttributedString.string,
            pageId: pageId,
            type: nil
        )
        let mentionAttachmentString = NSMutableAttributedString(attachment: mentionAttachment)
        let currentAttributes = mentionAttributedString.attributes(at: 0, effectiveRange: nil)
        mentionAttachmentString.addAttributes(
            currentAttributes,
            range: NSRange(
                location: 0,
                length: mentionAttachmentString.length
            )
        )
        attributedString.insert(mentionAttachmentString, at: range.location)
    }
    
    private func apply(_ action: MarkStyleAction, to old: [NSAttributedString.Key : Any]) -> AttributedStringChange? {
        switch action {
        case let .bold(shouldApplyMarkup):
            if let font = old[.font] as? UIFont {
                let oldTraits = font.fontDescriptor.symbolicTraits
                let traits = shouldApplyMarkup ? oldTraits.union(.traitBold) : oldTraits.symmetricDifference(.traitBold)
                if let newDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                    let newFont = UIFont(descriptor: newDescriptor, size: font.pointSize)
                    return AttributedStringChange(changeAttributes: [.font : newFont])
                }
            }
            return nil
        case let .italic(shouldApplyMarkup):
            if let font = old[.font] as? UIFont {
                let oldTraits = font.fontDescriptor.symbolicTraits
                let traits = shouldApplyMarkup ? oldTraits.union(.traitItalic) : oldTraits.symmetricDifference(.traitItalic)
                if let newDescriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                    let newFont = UIFont(descriptor: newDescriptor, size: font.pointSize)
                    return AttributedStringChange(changeAttributes:[.font : newFont])
                }
            }
            return nil
        case let .keyboard(hasStyle):
            return keyboardUpdate(
                with: old,
                shouldHaveStyle: hasStyle
            )
        case let .strikethrough(shouldApplyMarkup):
            return AttributedStringChange(
                changeAttributes: [.strikethroughStyle : shouldApplyMarkup ? NSUnderlineStyle.single.rawValue : 0]
            )
        case let .underscored(shouldApplyMarkup):
            return AttributedStringChange(
                changeAttributes: [.underlineStyle : shouldApplyMarkup ? NSUnderlineStyle.single.rawValue : 0]
            )
        case let .textColor(color):
            return AttributedStringChange(changeAttributes: [.foregroundColor : color as Any])
        case let .backgroundColor(color):
            return AttributedStringChange(changeAttributes: [.backgroundColor : color as Any])
        case let .link(url):
            return AttributedStringChange(
                changeAttributes: [.link : url as Any],
                deletedKeys: url.isNil ? [.link] : []
            )
        case let .mention(pageId):
            return AttributedStringChange(changeAttributes: [.mention: pageId as Any])
        }
    }
    
    private func keyboardUpdate(
        with attributes: [NSAttributedString.Key: Any],
        shouldHaveStyle: Bool
    ) -> AttributedStringChange? {
        guard let font = attributes[.font] as? UIFont else { return nil }
        
        var targetFont: UIFont
        switch (font.isCode, shouldHaveStyle) {
        case (true, true):
            return AttributedStringChange(changeAttributes: [.font: font])
        case (true, false):
            targetFont = defaultNonCodeFont
        case (false, true):
            targetFont = UIFont.code(of: font.pointSize)
        case (false, false):
            return AttributedStringChange(changeAttributes: [.font: font])
        }
        
        var traitsToApply = targetFont.fontDescriptor.symbolicTraits
        if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
            traitsToApply.insert(.traitBold)
        }
        if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
            traitsToApply.insert(.traitItalic)
        }
        if let newFontDescriptor = targetFont.fontDescriptor.withSymbolicTraits(traitsToApply) {
            return AttributedStringChange(changeAttributes: [.font: UIFont(descriptor: newFontDescriptor, size: font.pointSize)])
        }
        return AttributedStringChange(changeAttributes: [.font: targetFont])
    }
}
