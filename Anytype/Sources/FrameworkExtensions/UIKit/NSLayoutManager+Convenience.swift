import UIKit

extension NSLayoutManager {
    func rangeForAttachment(attachment: NSTextAttachment) -> NSRange? {
        guard let attributedString = textStorage, attributedString.length > 0 else { return nil }
        
        let range = attributedString.wholeRange
        var resultRange: NSRange?
        
        attributedString.enumerateAttribute(.attachment, in: range) { value, subrange, shouldStop in
            guard let foundAttachment = value as? NSTextAttachment,
                  foundAttachment === attachment else { return }
            resultRange = subrange
            shouldStop[0] = true
        }
        return resultRange
    }
    
    func rect(for textAttachment: NSTextAttachment) -> CGRect? {
        guard let attachmentRange = rangeForAttachment(attachment: textAttachment),
              let textContainer = textContainers.first else { return nil }
        var resultRect: CGRect?
        enumerateEnclosingRects(forGlyphRange: attachmentRange,
                                withinSelectedGlyphRange: NSRange(location: NSNotFound,
                                                                  length: 0),
                                in: textContainer) { rect, shouldStop in
            resultRect = rect
            shouldStop[0] = true
        }
        return resultRect
    }
}
