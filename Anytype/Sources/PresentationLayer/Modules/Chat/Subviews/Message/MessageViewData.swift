import Foundation
import Services

struct MessageViewData: Identifiable, Equatable, Hashable {
    let spaceId: String
    let objectId: String
    let chatId: String
    let message: ChatMessage
    let participant: Participant?
    let reactions: [MessageReactionModel]
    let attachmentsDetails: [MessageAttachmentDetails]
    let reply: ChatMessage?
    let replyAttachments: [MessageAttachmentDetails]
    let replyAuthor: Participant?
    
    var id: String {
        message.id
    }
}
