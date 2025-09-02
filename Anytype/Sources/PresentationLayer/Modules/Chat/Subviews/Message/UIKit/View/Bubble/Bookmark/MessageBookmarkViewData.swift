import Foundation

struct MessageBookmarkViewData: Equatable {
    let icon: Icon
    let title: String
    let description: String
    let style: MessageAttachmentStyle
}

extension MessageBookmarkViewData {
    init(details: MessageAttachmentDetails, position: MessageHorizontalPosition) {
        self.icon = details.objectIconImage
        self.title = details.source ?? details.title
        self.description = details.title
        self.style = position.isRight ? .messageYour : .messageOther
    }
}
