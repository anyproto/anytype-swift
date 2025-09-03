//import Foundation
//import Services
//
//struct MessageBookmarkViewData: Equatable, Hashable {
//    let messageId: String
//    let objectId: String
//    let icon: Icon
//    let title: String
//    let description: String
//    let style: MessageAttachmentStyle
//}
//
//extension MessageBookmarkViewData {
//    init(messageId: String, details: ObjectDetails, position: MessageHorizontalPosition) {
//        let source = details.source?.url.host() ?? details.source?.absoluteString
//        self.messageId = messageId
//        self.objectId = details.id
//        self.icon = details.objectIconImage
//        self.title = source ?? details.title
//        self.description = details.title
//        self.style = position.isRight ? .messageYour : .messageOther
//    }
//}
