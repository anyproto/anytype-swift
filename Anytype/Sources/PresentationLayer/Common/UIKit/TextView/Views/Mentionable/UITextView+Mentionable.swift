import UIKit

protocol Mentionable {
    @discardableResult func removeMentionIfNeeded(replacementRange: NSRange, replacementText: String) -> Bool
}

extension UITextView: Mentionable {

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
}
