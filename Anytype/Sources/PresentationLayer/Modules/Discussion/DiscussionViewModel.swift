import Foundation

@MainActor
final class DiscussionViewModel: ObservableObject {
    
    private let spaceId: String
    private weak var output: DiscussionModuleOutput?
    
    init(spaceId: String, output: DiscussionModuleOutput?) {
        self.spaceId = spaceId
        self.output = output
    }
    
    func onTapAddObjectToMessage() {
        let data = BlockObjectSearchData(
            title: Loc.linkTo,
            spaceId: spaceId,
            excludedObjectIds: [],
            excludedLayouts: [],
            onSelect: { details in
                // TODO: Handle Selected object
            }
        )
        output?.onLinkObjectSelected(data: data)
    }
}
