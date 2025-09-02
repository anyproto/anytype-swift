import UIKit

struct MessageReplyViewData: Equatable {
    let author: NSAttributedString
    let description: NSAttributedString
    let attachmentIcon: Icon?
    let isYour: Bool
    let messageYourBackgroundColor: UIColor
    
    init(
        author: String,
        description: String,
        attachmentIcon: Icon?,
        isYour: Bool,
        messageYourBackgroundColor: UIColor
    ) {
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

extension MessageReplyViewData {
    init(model: MessageReplyModel) {
        self.init(
            author: model.author,
            description: model.description,
            attachmentIcon: model.attachmentIcon,
            isYour: model.isYour,
            messageYourBackgroundColor: .black.withAlphaComponent(0.5)
        )
    }
}
