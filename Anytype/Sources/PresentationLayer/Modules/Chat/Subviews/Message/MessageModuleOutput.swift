import Foundation
import Services

@MainActor
protocol MessageModuleOutput: AnyObject {
    func didSelectAddReaction(message: MessageUIViewData)
    func didTapOnReaction(message: MessageUIViewData, emoji: String)
    func didLongTapOnReaction(message: MessageUIViewData, reaction: MessageReactionData)
    func didSelectAttachment(message: MessageUIViewData, objectId: String)
    func didSelectReplyTo(message: MessageUIViewData)
    func didSelectReply(message: MessageUIViewData)
    func didSelectDelete(message: MessageUIViewData)
    func didSelectCopyPlainText(message: MessageUIViewData)
    func didSelectEdit(message: MessageUIViewData)
    func didSelectAuthor(authorId: String)
    func didSelectUnread(message: MessageUIViewData)
}
