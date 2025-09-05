import UIKit
import StoredHashMacro

@StoredHash
struct MessageReplyViewData: Equatable, Hashable {
    let replyMessageId: String
    let author: NSAttributedString
    let description: NSAttributedString
    let attachmentIcon: Icon?
    let isYour: Bool
    let messageYourBackgroundColor: UIColor
    
    init(
        replyMessageId: String,
        author: String,
        description: String,
        attachmentIcon: Icon?,
        isYour: Bool,
        messageYourBackgroundColor: UIColor
    ) {
        self.replyMessageId = replyMessageId
        self.author = NSAttributedString(
            string: author.isNotEmpty ? author : " ", // Safe height if participant is not loaded
            attributes: [.font: UIFont.caption1Medium]
        )
        self.description = NSAttributedString(
            string: description,
            attributes: [.font: UIFont.caption1Regular]
        )
        self.attachmentIcon = attachmentIcon
        self.isYour = isYour
        self.messageYourBackgroundColor = messageYourBackgroundColor
    }
}
