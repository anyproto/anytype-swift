import UIKit

extension NSLayoutManager {
    func rangeForAttachment(attachment: NSTextAttachment) -> NSRange? {
        guard let attributedString = textStorage, attributedString.length > 0 else { return nil }
        
        let range = NSRange(location: 0, length: attributedString.length)
        var resultRange: NSRange?
        
        attributedString.enumerateAttribute(.attachment, in: range) { value, subrange, shouldStop in
            guard let foundAttachment = value as? NSTextAttachment,
                  foundAttachment == attachment else { return }
            resultRange = subrange
            shouldStop[0] = true
        }
        return resultRange
    }
}
