import UIKit

extension UITextView: Mentionable {
    
    func removeMentionIfNeeded(replacementRange: NSRange, replacementText: String) {
        guard replacementText == "" else { return }
        let mentionSearchRange = NSRange(location: 0, length: selectedRange.location)
        
        attributedText.enumerateAttribute(.mention, in: mentionSearchRange) { value, subrange, shouldStop in
            guard value is String,
                  subrange.location + subrange.length == selectedRange.location else { return }
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            removeMentionInteractionButton(from: subrange)
            mutableAttributedString.deleteCharacters(in: subrange)
            attributedText = mutableAttributedString
            shouldStop[0] = true
        }
    }
    
    func insert(_ mention: MentionObject,
                from: UITextPosition,
                to: UITextPosition) {
        guard let name = mention.name else { return }
        let pageId = mention.id
        let length = offset(from: from, to: to)
        let location = offset(from: beginningOfDocument, to: from)
        let replacementRange = NSRange(location: location, length: length)
        let attributedString = NSMutableAttributedString(attributedString: attributedText)
        attributedString.deleteCharacters(in: replacementRange)
        
        let mentionAttachment = MentionAttachment(name: name, pageId: pageId, iconData: mention.iconData)
        let mentionsString = NSMutableAttributedString(attachment: mentionAttachment)
        let mentionNameString = NSAttributedString(string: name,
                                                   attributes: [.mention: pageId,
                                                                .font: font ?? .bodyFont])
        mentionsString.append(mentionNameString)
        
        attributedString.insert(mentionsString, at: location)
        attributedText = attributedString
    }
    
    private func removeMentionInteractionButton(from range: NSRange) {
        guard let start = position(from: beginningOfDocument, offset: range.location),
              let end = position(from: start, offset: range.length),
              let textRange = textRange(from: start, to: end) else { return }
        let rect = firstRect(for: textRange)
        let view = hitTest(CGPoint(x: rect.midX, y: rect.midY), with: nil)
        if view is MentionButton {
            view?.removeFromSuperview()
        }
    }
}
