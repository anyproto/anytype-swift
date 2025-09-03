import UIKit

struct MessageReplyViewData: Equatable, Hashable {
    let messageId: String
    let author: NSAttributedString
    let description: NSAttributedString
    let attachmentIcon: Icon?
    let isYour: Bool
    let messageYourBackgroundColor: UIColor
    
    init(
        messageId: String,
        author: String,
        description: String,
        attachmentIcon: Icon?,
        isYour: Bool,
        messageYourBackgroundColor: UIColor
    ) {
        self.messageId = messageId
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
