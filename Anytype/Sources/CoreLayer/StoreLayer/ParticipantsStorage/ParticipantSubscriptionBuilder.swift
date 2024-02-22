import Foundation
import Services

protocol ParticipantsSubscriptionBuilderProtocol: AnyObject {
    var subscriptionId: String { get }
    func build() -> SubscriptionData
}

final class ParticipantsSubscriptionBuilder: ParticipantsSubscriptionBuilderProtocol {
    
    let subscriptionId = "Participants-\(UUID().uuidString)"
    
    func build() -> SubscriptionData {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters = [
            SearchHelper.notHiddenFilter(),
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.isDeletedFilter(isDeleted: false),
            SearchHelper.layoutFilter([.participant])
        ]
        
        return .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: .builder {
                    BundledRelationKey.objectListKeys.map { $0.rawValue }
                    BundledRelationKey.participantStatus.rawValue
                    BundledRelationKey.participantPermissions.rawValue
                    BundledRelationKey.identity.rawValue
                }
            )
        )
    }
}
