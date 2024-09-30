import Foundation
import Services

protocol ObjectTypeSubscriptionDataBuilderProtocol: AnyObject {
    func build(spaceId: String, subId: String) -> SubscriptionData
}

final class ObjectTypeSubscriptionDataBuilder: ObjectTypeSubscriptionDataBuilderProtocol {
    
    // MARK: - ObjectTypeSubscriptionDataBuilderProtocol
    
    func build(spaceId: String, subId: String) -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        let filters = [
            SearchHelper.layoutFilter([DetailsLayout.objectType])
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
