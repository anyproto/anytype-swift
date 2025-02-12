import Foundation
import Services

@MainActor
protocol MessageModuleOutput: AnyObject {
    func didSelectAddReaction(messageId: String)
    func didTapOnReaction(data: MessageViewData, reaction: MessageReactionModel) async throws
    func didLongTapOnReaction(data: MessageViewData, reaction: MessageReactionModel)
    func didSelectAttachment(data: MessageViewData, details: MessageAttachmentDetails)
    func didSelectAttachment(data: MessageViewData, details: ObjectDetails)
    func didSelectReplyTo(message: MessageViewData)
    func didSelectReplyMessage(message: MessageViewData)
    func didSelectDeleteMessage(message: MessageViewData)
    func didSelectEditMessage(message: MessageViewData) async
    func didSelectAuthor(authorId: String)
}
