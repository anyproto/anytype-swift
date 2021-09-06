import UIKit

extension UITextView: Mentionable {
    
    private enum Constants {
        static let attachmentLenght = 1
    }
    
    func removeMentionIfNeeded(replacementRange: NSRange, replacementText: String) -> Bool {
        guard replacementText == "" else { return false }
        let mentionSearchRange = NSRange(location: 0, length: selectedRange.location)
        
        var result = false
        attributedText.enumerateAttribute(.mention, in: mentionSearchRange) { value, subrange, shouldStop in
            guard value is String,
                  subrange.location + subrange.length == selectedRange.location else { return }

            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedString.deleteCharacters(in: subrange)
            result = true

            // If we will set empty attributed string it will erase all typing attributes
            if mutableAttributedString.length == 0 {
                let oldTypingAttributes = typingAttributes
                attributedText = mutableAttributedString
                typingAttributes = oldTypingAttributes
            } else {
                attributedText = mutableAttributedString
            }

            selectedRange = NSRange(location: subrange.location, length: 0)
            shouldStop[0] = true
        }
        return result
    }
    
    func insert(
        _ mention: MentionObject,
        from: UITextPosition,
        to: UITextPosition
    ) {
        guard let name = mention.name else { return }
        let pageId = mention.id
        let length = offset(from: from, to: to)
        let location = offset(from: beginningOfDocument, to: from)
        let replacementRange = NSRange(location: location, length: length)
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        attributedString.deleteCharacters(in: replacementRange)
        attributedText = attributedString
        insertStringToAttributedString(
            name,
            location: location
        )
        let modifier = MarkStyleModifier(
            attributedText: NSMutableAttributedString(attributedString: attributedText),
            defaultNonCodeFont: .bodyRegular
        )
        modifier.apply(
            .mention(pageId),
            range: NSRange(
                location: location,
                length: name.count
            )
        )
        attributedText = NSAttributedString(attributedString: modifier.attributedString)
        selectedRange = NSRange(location: location + name.count + Constants.attachmentLenght, length: 0)
    }
}
