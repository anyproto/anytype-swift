import Foundation
import Services

@MainActor
protocol MessageModuleOutput: AnyObject {
    func didSelectAddReaction(messageId: String)
    func didLongTapOnReaction(data: MessageParticipantsReactionData)
    func didSelectObject(details: MessageAttachmentDetails)
    func didSelectReplyTo(message: MessageViewData)
    func didSelectReplyMessage(message: MessageViewData)
    func didSelectDeleteMessage(message: MessageViewData)
}
