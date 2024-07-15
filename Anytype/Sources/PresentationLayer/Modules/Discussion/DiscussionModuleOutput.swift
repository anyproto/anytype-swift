import Foundation

protocol DiscussionModuleOutput: AnyObject {
    func onLinkObjectSelected(data: BlockObjectSearchData)
}
