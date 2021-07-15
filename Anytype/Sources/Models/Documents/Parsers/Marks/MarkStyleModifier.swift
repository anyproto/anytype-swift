import UIKit

final class MarkStyleModifier {
    
    typealias MarkStyle = MiddlewareModelsModule.Parsers.Text.AttributedText.MarkStyle
    
    let attributedString: NSMutableAttributedString
    
    init(attributedText: NSMutableAttributedString = .init()) {
        attributedString = attributedText
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
        // TODO: We still DON'T check range and attributedString length here. Fix it.
        guard attributedString.length > range.location + range.length else { return [:] }
        return attributedString.attributes(at: range.lowerBound, longestEffectiveRange: nil, in: range)
    }
    
    private func mergeAttributes(origin: [NSAttributedString.Key : Any], changes: [NSAttributedString.Key : Any]) -> [NSAttributedString.Key : Any] {
        var result = origin
        result.merge(changes) { (source, target) in target }
        return result
    }
    
    // MARK: Applying style
    private func applyStyle(style: MarkStyle, range: NSRange) {
        let oldAttributes = getAttributes(at: range)
        let update = style.to(old: oldAttributes)
        
        let changedAttributes = update.attributes()
        let deletedKeys = update.deletedKeys()
        
        var newAttributes = self.mergeAttributes(origin: oldAttributes, changes: changedAttributes)
        for key in deletedKeys {
            newAttributes.removeValue(forKey: key)
            attributedString.removeAttribute(key, range: range)
        }

        attributedString.addAttributes(newAttributes, range: range)
        if case let .mention(id) = style, let pageId = id {
            // This attachment is for displaying icon in front of mention: 🦊Fox
            let mentionAttributedString = attributedString.attributedSubstring(from: range)
            let mentionAttachment = MentionAttachment(name: mentionAttributedString.string, pageId: pageId)
            let mentionAttachmentString = NSMutableAttributedString(attachment: mentionAttachment)
            if let font = mentionAttributedString.attribute(.font, at: 0, effectiveRange: nil) {
                mentionAttachmentString.addAttribute(
                    .font,
                    value: font,
                    range: NSRange(location: 0, length: mentionAttachmentString.length))
            }
            attributedString.insert(mentionAttachmentString, at: range.location)
        }
    }
    
    func applyStyle(style: MarkStyle, rangeOrWholeString either: RangedEither<NSRange, Bool>) {
        switch either {
        case let .range(value):
            applyStyle(style: style, range: value)
        case let .whole(whole):
            if whole {
                applyStyle(style: style, range: NSRange(location: 0, length: attributedString.length))
            }
        }
    }
    
    // MARK: Get Mark Styles
    private func getMarkStyles(at range: NSRange) -> [MarkStyle] {
        MarkStyle.from(attributes: getAttributes(at: range))
    }
    
    /// Get all MarkStyles from a RangeEither ( .whole(Bool) or .range(Range)
    /// - Parameter either: Span parameter. It could be `.whole(Bool)` or `.range(Range)`
    /// - Returns: Returns list of marks that it finds in a span.
    func getMarkStyles(at either: RangedEither<NSRange, Bool>) -> [MarkStyle] {
        switch either {
        case let .range(value): return getMarkStyles(at: value)
        case let .whole(value): return value ? getMarkStyles(at: NSRange(location: 0, length: attributedString.length)) : []
        }
    }
}
