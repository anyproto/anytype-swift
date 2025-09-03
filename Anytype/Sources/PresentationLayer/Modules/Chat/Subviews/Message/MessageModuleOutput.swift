import Foundation
import Services

@MainActor
protocol MessageModuleOutput: AnyObject {
    func didSelectAddReaction(data: MessageUIViewData)
    func didTapOnReaction(data: MessageUIViewData, emoji: String)
    func didLongTapOnReaction(data: MessageUIViewData, reaction: MessageReactionData)
    func didSelectAttachment(data: MessageUIViewData, objectId: String)
    func didSelectReplyTo(data: MessageUIViewData)
    func didSelectReplyMessage(data: MessageUIViewData)
    func didSelectDeleteMessage(message: MessageViewData)
    func didSelectCopyPlainText(message: MessageViewData)
    func didSelectEditMessage(message: MessageViewData) async
    func didSelectAuthor(authorId: String)
    func didSelectUnread(message: MessageViewData) async throws
}
