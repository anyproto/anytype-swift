import Foundation

final class DiscussionCoordinatorViewModel: ObservableObject, DiscussionModuleOutput {
    
    let spaceId: String
    @Published var objectToMessageSearchData: BlockObjectSearchData?
    
    init(data: EditorDiscussionObject) {
        self.spaceId = data.spaceId
    }
    
    func onLinkObjectSelected(data: BlockObjectSearchData) {
        objectToMessageSearchData = data
    }
}
