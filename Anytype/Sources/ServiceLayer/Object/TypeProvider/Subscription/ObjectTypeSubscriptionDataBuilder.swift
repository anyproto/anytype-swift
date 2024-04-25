import Foundation
import Services

protocol ObjectTypeSubscriptionDataBuilderProtocol: AnyObject {
    func build() -> SubscriptionData
}

final class ObjectTypeSubscriptionDataBuilder: ObjectTypeSubscriptionDataBuilderProtocol {
    
    private let accountManager: AccountManagerProtocol
    
    init(accountManager: AccountManagerProtocol) {
        self.accountManager = accountManager
    }
    
    // MARK: - RelationSubscriptionDataBuilderProtocol
    
    func build() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        let filters = [
            SearchHelper.layoutFilter([DetailsLayout.objectType])
        ]
        
        return .search(
            SubscriptionData.Search(
                identifier: ObjectTypeProvider.subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: ObjectType.subscriptionKeys.map(\.rawValue)
            )
        )
    }
}
