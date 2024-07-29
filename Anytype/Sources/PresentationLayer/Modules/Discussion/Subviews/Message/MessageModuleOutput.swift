import Foundation

protocol MessageModuleOutput: AnyObject {
    func didSelectAddReaction(messageId: String)
}
