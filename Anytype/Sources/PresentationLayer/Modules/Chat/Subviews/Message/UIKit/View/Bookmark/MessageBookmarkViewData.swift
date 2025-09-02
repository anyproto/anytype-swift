import Foundation

struct MessageBookmarkViewData: Equatable {
    let messageId: String
    let objectId: String
    let icon: Icon
    let title: String
    let description: String
    let style: MessageAttachmentStyle
}

extension MessageBookmarkViewData {
    init(messageId: String, details: MessageAttachmentDetails, position: MessageHorizontalPosition) {
        self.messageId = messageId
        self.objectId = details.id
        self.icon = details.objectIconImage
        self.title = details.source ?? details.title
        self.description = details.title
        self.style = position.isRight ? .messageYour : .messageOther
    }
}
