import Foundation
import Services

@MainActor
protocol MessageModuleOutput: AnyObject {
    func didSelectAddReaction(messageId: String)
    func didTapOnReaction(data: MessageViewData,  emoji: String) async throws
    func didLongTapOnReaction(data: MessageViewData, reaction: MessageReactionModel)
    func didSelectAttachment(data: MessageViewData, details: MessageAttachmentDetails)
    func didSelectAttachment(data: MessageViewData, details: ObjectDetails)
    func didSelectReplyTo(message: MessageViewData)
    func didSelectReplyMessage(message: MessageViewData)
    func didSelectDeleteMessage(message: MessageViewData)
    func didSelectCopyPlainText(message: MessageViewData)
    func didSelectEditMessage(message: MessageViewData) async
    func didSelectAuthor(authorId: String)
    func didSelectUnread(message: MessageViewData) async throws
    
    // New methods
    
//    func didSelectAttachment(messageId: String, objectId: String)
//    func didSelectReplyMessage(messageId: String)
}
