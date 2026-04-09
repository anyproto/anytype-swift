import Foundation
import Services
import AnytypeCore
import StoredHashMacro

@StoredHash
struct MessageViewData: Identifiable, Equatable, Hashable {
    let spaceId: String
    let chatId: String
    let authorName: String
    let authorIcon: Icon
    let authorId: String?
    let timestampLabel: String
    let messageString: AttributedString
    let discussionBlocks: [DiscussionBlockItem]
    let replyModel: MessageReplyModel?
    let position: MessageHorizontalPosition
    let linkedObjects: MessageLinkedObjectsLayout?
    let reactions: [MessageReactionModel]
    let canAddReaction: Bool
    let canToggleReaction: Bool
    let canReply: Bool
    let nextSpacing: MessageViewSpacing
    let authorIconMode: MessageAuthorIconMode
    let showAuthorName: Bool
    let canDelete: Bool
    let canEdit: Bool
    let showMessageSyncIndicator: Bool
    let isMember: Bool
    let isReply: Bool
    let isLastReply: Bool

    // Raw data for action logic
    let message: ChatMessage
    let attachmentsDetails: [ObjectDetails]
    let reply: ChatMessage?
    
    var id: String {
        message.id
    }
}
