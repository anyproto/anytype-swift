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
    
    func applyStyle(style: MarkStyle, range: NSRange) {
        guard range.location >= 0, attributedString.length >= range.length else {
            anytypeAssertionFailure("Range out of bounds in \(#function)")
            return
        }
        switch style {
        case .bold,
             .italic,
             .keyboard,
             .backgroundColor,
             .textColor,
             .link,
             .underscored,
             .strikethrough:
            applyStyle(style, toAllSubrangesIn: range)
        case .mention:
            applyStyle(style, toWhole: range)
        }
    }
    
    private func applyStyle(_ style: MarkStyle, toWhole range: NSRange) {
        let oldAttributes = getAttributes(at: range)
        let update = style.to(
            old: oldAttributes,
            nonCodeFont: defaultNonCodeFont
        )
        
        let changedAttributes = update.attributes()
        let deletedKeys = update.deletedKeys()
        
        var newAttributes = mergeAttributes(
            origin: oldAttributes,
            changes: changedAttributes
        )
        for key in deletedKeys {
            newAttributes.removeValue(forKey: key)
            attributedString.removeAttribute(key, range: range)
        }

        attributedString.addAttributes(newAttributes, range: range)
        if case let .mention(id) = style, let pageId = id {
            applyMention(pageId: pageId, range: range)
        }
    }
    
    private func applyStyle(_ style: MarkStyle, toAllSubrangesIn range: NSRange) {
        attributedString.enumerateAttributes(in: range) { _, subrange, _ in
            applyStyle(style, toWhole: subrange)
        }
    }
    
    private func applyMention(pageId: String, range: NSRange) {
        // This attachment is for displaying icon in front of mention: 🦊Fox
        let mentionAttributedString = attributedString.attributedSubstring(from: range)
        let mentionAttachment = MentionAttachment(name: mentionAttributedString.string, pageId: pageId)
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
}
