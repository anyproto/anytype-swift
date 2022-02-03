import AnytypeCore
import UIKit

final class MarkStyleModifier {
    let attributedString: NSMutableAttributedString
    private let anytypeFont: AnytypeFont
    
    init(attributedString: NSMutableAttributedString, anytypeFont: AnytypeFont) {
        self.attributedString = attributedString
        self.anytypeFont = anytypeFont
    }
    
    convenience init(attributedString: NSAttributedString, anytypeFont: AnytypeFont) {
        self.init(
            attributedString: NSMutableAttributedString(attributedString: attributedString),
            anytypeFont: anytypeFont
        )
    }
        
    func apply(_ action: MarkupType, shouldApplyMarkup: Bool, range: NSRange) {
        guard attributedString.isRangeValid(range) else {
            anytypeAssertionFailure("Range out of bounds in \(#function)", domain: .markStyleModifier)
            return
        }
        
        switch action {
        case .mention:
            applySingleAction(action, shouldApplyMarkup: shouldApplyMarkup, range: range)
        case .emoji:
            applySingleAction(action, shouldApplyMarkup: shouldApplyMarkup, range: range)
        default:
            attributedString.enumerateAttributes(in: range) { _, subrange, _ in
                applySingleAction(action, shouldApplyMarkup: shouldApplyMarkup, range: subrange)
            }
        }
    }
    
    private func applySingleAction(_ action: MarkupType, shouldApplyMarkup: Bool, range: NSRange) {
        let oldAttributes = getAttributes(at: range)
        guard let update = apply(action, shouldApplyMarkup: shouldApplyMarkup, to: oldAttributes) else { return }

        var newAttributes = oldAttributes.merging(update.changeAttributes) { old, new in new }
        for key in update.deletedKeys {
            newAttributes.removeValue(forKey: key)
            attributedString.removeAttribute(key, range: range)
        }

        attributedString.addAttributes(newAttributes, range: range)
        if case let .mention(data) = action {
            addMentionIcon(data: data, range: range, font: anytypeFont)
        }
        if case let .emoji(data) = action {
            addEmoji(data: data, range: range, font: anytypeFont)
        }
    }

    private func getAttributes(at range: NSRange) -> [NSAttributedString.Key : Any] {
        switch (attributedString.string.isEmpty, range) {
        // isEmpty & range == zero(0, 0) - assuming that we deleted text. So, we need to apply default typing attributes that are coming from textView.
        case (true, NSRange.zero): return [:]

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
    
    private func apply(_ action: MarkupType, shouldApplyMarkup: Bool, to old: [NSAttributedString.Key : Any]) -> AttributedStringChange? {
        switch action {
        case .bold:
            guard let oldFont = old[.font] as? UIFont else { return nil }

            let newFont = shouldApplyMarkup ? oldFont.bold : oldFont.regular
            return AttributedStringChange(changeAttributes: [.font : newFont])


        case .italic:
            guard let oldFont = old[.font] as? UIFont else { return nil }

            let newFont = shouldApplyMarkup ? oldFont.italic : oldFont.nonItalic
            return AttributedStringChange(changeAttributes: [.font : newFont])

        case .keyboard:
            return keyboardUpdate(with: old, shouldHaveStyle: shouldApplyMarkup)
        case .strikethrough:
            return AttributedStringChange(
                changeAttributes: [.strikethroughStyle : shouldApplyMarkup ? NSUnderlineStyle.single.rawValue : 0]
            )

        case .underscored:
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
        case let .linkToObject(blockId):
            return AttributedStringChange(
                changeAttributes: [
                    .linkToObject: blockId as Any,
                    .localUnderline: true
                ],
                deletedKeys: blockId?.isEmpty ?? true ? [.linkToObject, .localUnderline] : []
            )
        case let .mention(data):
            return mentionUpdate(data: data)
        case let .emoji(data):
            return emojiUpdate(data: data)
        }
    }
    
    private func emojiUpdate(data: Emoji) -> AttributedStringChange {
        return AttributedStringChange(changeAttributes: [ .emoji: data ])
    }
    
    private func mentionUpdate(data: MentionData) -> AttributedStringChange {
        let deletedStyle = data.isDeleted || data.isArchived
        
        var changeAttributes: [NSAttributedString.Key: Any] = [
            .mention: data.blockId,
            .localUnderline: deletedStyle ? false : true
        ]
        if deletedStyle { changeAttributes[.foregroundColor] = UIColor.textTertiary }
        
        return AttributedStringChange(changeAttributes: changeAttributes)
    }
    
    private func addMentionIcon(data: MentionData, range: NSRange, font: AnytypeFont) {
        let mentionAttributedString = attributedString.attributedSubstring(from: range)
        guard mentionAttributedString.string.isNotEmpty else {
            // Empty string is for deleted mentions
            return
        }
        
        var iconAttributes = mentionAttributedString.attributes(at: 0, effectiveRange: nil)
        iconAttributes.removeValue(forKey: .localUnderline) // no underline under icon
        
        let mentionIcon = data.isDeleted ? ObjectIconImage.staticImage(ImageName.ghost) : data.image
        let mentionAttachment = MentionAttachment(icon: mentionIcon, size: font.mentionType)
        let mentionAttachmentString = NSMutableAttributedString(attachment: mentionAttachment)
        mentionAttachmentString.addAttributes(iconAttributes, range: mentionAttachmentString.wholeRange)
        
        attributedString.insert(mentionAttachmentString, at: range.location)
    }
    
    private func addEmoji(data: Emoji, range: NSRange, font: AnytypeFont) {
        let emojiAttributedString = attributedString.attributedSubstring(from: range)
        guard emojiAttributedString.string.isNotEmpty else {
            // Empty string is for deleted emoji
            return
        }
        
        var iconAttributes = emojiAttributedString.attributes(at: 0, effectiveRange: nil)
        iconAttributes.removeValue(forKey: .localUnderline) // no underline under icon
        
        let attachment = MentionAttachment(icon: .icon(.emoji(data)), size: font.mentionType)
        let attachmentString = NSMutableAttributedString(attachment: attachment)
        attachmentString.addAttributes(iconAttributes, range: attachmentString.wholeRange)
        
        attributedString.replaceCharacters(in: range, with: attachmentString)
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
            targetFont = anytypeFont.uiKitFont
        case (false, true):
            targetFont = UIFont.code(of: font.pointSize)
        case (false, false):
            return AttributedStringChange(changeAttributes: [.font: font])
        }
        
        var newFontDescriptor = targetFont.fontDescriptor
        newFontDescriptor = newFontDescriptor.withSymbolicTraits(font.fontDescriptor.symbolicTraits) ?? newFontDescriptor

        return AttributedStringChange(changeAttributes: [.font: UIFont(descriptor: newFontDescriptor, size: font.pointSize)])
    }
}
