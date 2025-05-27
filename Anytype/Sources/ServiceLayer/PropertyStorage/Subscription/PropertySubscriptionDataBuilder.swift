import Foundation
import Services

final class PropertySubscriptionDataBuilder: MultispaceSubscriptionDataBuilderProtocol {
    // MARK: - MultispaceSubscriptionDataBuilderProtocol
    
    func build(accountId: String, spaceId: String, subId: String) -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        let filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.layoutFilter([.relation])
        ]
        
        return .search(
            SubscriptionData.Search(
                identifier: subId,
                spaceId: spaceId,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: RelationDetails.subscriptionKeys.map(\.rawValue),
                noDepSubscription: true
            )
        )
    }
}
