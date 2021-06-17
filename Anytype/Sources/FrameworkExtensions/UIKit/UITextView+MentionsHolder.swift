import UIKit

extension UITextView: Mentionable {
    
    func removeMentionIfNeeded(replacementRange: NSRange, replacementText: String) {
        guard replacementText == "" else { return }
        let mentionSearchRange = NSRange(location: 0, length: selectedRange.location)
        
        attributedText.enumerateAttribute(.mention, in: mentionSearchRange) { value, subrange, shouldStop in
            guard value is String,
                  subrange.location + subrange.length == selectedRange.location else { return }
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedString.deleteCharacters(in: subrange)
            attributedText = mutableAttributedString
            shouldStop[0] = true
        }
    }
}
