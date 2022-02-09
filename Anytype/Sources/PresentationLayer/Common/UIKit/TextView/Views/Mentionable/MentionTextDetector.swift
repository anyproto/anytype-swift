import UIKit

protocol MentionTextDetectorProtocol {
    func removeMentionIfNeeded(textView: UITextView, replacementText: String) -> Bool
}

final class MentionTextDetector {
    func removeMentionIfNeeded(textView: UITextView, replacementText: String) -> Bool {
        guard replacementText == "" else { return false }
        let mentionSearchRange = NSRange(location: 0, length: textView.selectedRange.location)

        var result = false
        textView.attributedText.enumerateAttribute(.mention, in: mentionSearchRange) { value, subrange, shouldStop in
            guard value is String,
                  subrange.location + subrange.length == textView.selectedRange.location else { return }

            let mutableAttributedString = NSMutableAttributedString(attributedString: textView.attributedText)
            mutableAttributedString.deleteCharacters(in: subrange)
            result = true

            // If we will set empty attributed string it will erase all typing attributes
            if mutableAttributedString.length == 0 {
                let oldTypingAttributes = textView.typingAttributes
                textView.attributedText = mutableAttributedString
                textView.typingAttributes = oldTypingAttributes
            } else {
                textView.attributedText = mutableAttributedString
            }

            textView.selectedRange = NSRange(location: subrange.location, length: 0)
            shouldStop[0] = true
        }
        return result
    }
}
