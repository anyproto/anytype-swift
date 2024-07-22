import Foundation

protocol DiscussionModuleOutput: AnyObject {
    func onLinkObjectSelected(data: BlockObjectSearchData)
    func didSelectAddReaction(messageId: String)
}
