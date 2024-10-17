import Foundation
import Services

@MainActor
protocol MessageModuleOutput: AnyObject {
    func didSelectAddReaction(messageId: String)
    func didSelectObject(details: MessageAttachmentDetails)
    func didSelectReplyTo(message: MessageViewData)
    func didSelectReplyMessage(message: MessageViewData)
}
