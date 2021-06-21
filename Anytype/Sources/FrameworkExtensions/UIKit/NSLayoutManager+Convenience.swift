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
    
    func rect(for mention: MentionAttachment) -> CGRect? {
        guard let attributedString = textStorage,
              attributedString.length > 0,
              let textContainer = textContainers.first else { return nil }
        var mentionAttachmentRange: NSRange?
        attributedString.enumerateAttribute(.attachment,
                                            in: NSRange(location: 0,
                                                        length: attributedString.length)) { value, subrange, shouldStop in
            guard let attachment = value as? MentionAttachment,
                  attachment === mention else { return }
            mentionAttachmentRange = subrange
            shouldStop[0] = true
        }
        guard let mentionRange = mentionAttachmentRange else { return nil }
        var resultRect: CGRect?
        let wholeMentionRange = NSRange(location: mentionRange.location,
                                        length: mentionRange.length + mention.name.count)
        enumerateEnclosingRects(forGlyphRange: wholeMentionRange,
                                               withinSelectedGlyphRange: NSRange(location: NSNotFound,
                                                                                 length: 0),
                                               in: textContainer) { rect, shouldStop in
            resultRect = rect
            shouldStop[0] = true
        }
        return resultRect
    }
}
