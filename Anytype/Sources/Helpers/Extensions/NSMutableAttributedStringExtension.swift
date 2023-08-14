import Foundation

extension NSMutableAttributedString {
    
    func removeAllMentionAttachmets() {
        var attachmentRanges = [NSRange]()
        enumerateAttribute(
            .attachment,
            in: NSRange(location: 0, length: length)
        ) { attachment, range, _ in
            guard attachment is IconTextAttachment else { return }
            attachmentRanges.append(range)
        }
        attachmentRanges.reversed().forEach { deleteCharacters(in: $0) }
    }
}
