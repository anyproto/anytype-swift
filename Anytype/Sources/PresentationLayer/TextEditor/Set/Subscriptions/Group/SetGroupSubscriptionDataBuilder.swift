import Foundation
import Services

@MainActor
protocol SetGroupSubscriptionDataBuilderProtocol {
    
    var groupSubscriptionId: String { get }
    
    func groupsData(_ setDocument: SetDocumentProtocol) -> GroupsSubscriptionData
}

@MainActor
final class SetGroupSubscriptionDataBuilder: SetGroupSubscriptionDataBuilderProtocol {
    
    let groupSubscriptionId = "Set.Groups-\(UUID().uuidString)"
    
    func groupsData(_ setDocument: SetDocumentProtocol) -> GroupsSubscriptionData {
        GroupsSubscriptionData(
            identifier: groupSubscriptionId,
            relationKey: setDocument.activeView.groupRelationKey,
            filters: setDocument.activeView.filters,
            source: setDocument.details?.setOf,
            collectionId: setDocument.isCollection() ? setDocument.objectId : nil
        )
    }
}
