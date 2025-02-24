import Foundation
import Services

struct MessageViewData: Identifiable, Equatable, Hashable {
    let spaceId: String
    let chatId: String
    let authorName: String
    let authorIcon: Icon
    let authorId: String?
    let createDate: String
    let messageString: AttributedString
    let replyModel: MessageReplyModel?
    let position: MessageHorizontalPosition
    let linkedObjects: MessageLinkedObjectsLayout?
    let reactions: [MessageReactionModel]
    let canAddReaction: Bool
    let nextSpacing: MessageViewSpacing
    let authorIconMode: MessageAuthorIconMode
    let showAuthorName: Bool
    let canDelete: Bool
    let canEdit: Bool
    
    // Raw data for action logic
    let message: ChatMessage
    let attachmentsDetails: [ObjectDetails]
    let reply: ChatMessage?
    
    var id: String {
        message.id
    }
}
