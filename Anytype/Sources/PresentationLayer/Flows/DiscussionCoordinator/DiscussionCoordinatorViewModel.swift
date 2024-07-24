import Foundation

final class DiscussionCoordinatorViewModel: ObservableObject, DiscussionModuleOutput {
    
    let objectId: String
    let spaceId: String
    @Published var objectToMessageSearchData: BlockObjectSearchData?
    @Published var showEmojiForMessageId: StringIdentifiable?
    
    init(data: EditorDiscussionObject) {
        self.objectId = data.objectId
        self.spaceId = data.spaceId
    }
    
    func onLinkObjectSelected(data: BlockObjectSearchData) {
        objectToMessageSearchData = data
    }
    
    func didSelectAddReaction(messageId: String) {
        showEmojiForMessageId = messageId.identifiable
    }
}
