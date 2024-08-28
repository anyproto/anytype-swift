import Foundation

@MainActor
protocol MessageModuleOutput: AnyObject {
    func didSelectAddReaction(messageId: String)
}
