import Foundation
import Services

final class ObjectTypeSubscriptionDataBuilder: MultispaceSubscriptionDataBuilderProtocol {
    
    // MARK: - MultispaceSubscriptionDataBuilderProtocol
    
    func build(accountId: String, spaceId: String, subId: String) -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        let filters = [
            SearchHelper.layoutFilter([DetailsLayout.objectType]),
            SearchHelper.filterOutTypeType()
        ]
        
        return .search(
            SubscriptionData.Search(
                identifier: subId,
                spaceId: spaceId,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: ObjectType.subscriptionKeys.map(\.rawValue),
                noDepSubscription: true
            )
        )
    }
}
