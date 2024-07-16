import Foundation
import Services
import SwiftUI

@MainActor
final class DiscussionViewModel: ObservableObject {
    
    private let spaceId: String
    private weak var output: DiscussionModuleOutput?
    
    @Published var linkedObjects: [ObjectDetails] = []
    
    init(spaceId: String, output: DiscussionModuleOutput?) {
        self.spaceId = spaceId
        self.output = output
    }
    
    func onTapAddObjectToMessage() {
        let data = BlockObjectSearchData(
            title: Loc.linkTo,
            spaceId: spaceId,
            excludedObjectIds: linkedObjects.map(\.id),
            excludedLayouts: [],
            onSelect: { [weak self] details in
                self?.linkedObjects.append(details)
            }
        )
        output?.onLinkObjectSelected(data: data)
    }
    
    func onTapRemoveLinkedObject(details: ObjectDetails) {
        withAnimation {
            linkedObjects.removeAll { $0.id == details.id }
        }
    }
}
