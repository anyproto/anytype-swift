import Foundation
import Services

extension SubscriptionId {
    static var objectType = SubscriptionId(value: "SubscriptionId.ObjectType")
}

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
            SearchHelper.layoutFilter([DetailsLayout.objectType])//,
//            SearchHelper.spaceId(accountManager.account.info.accountSpaceId)
        ]
        
        let keys = [
            BundledRelationKey.id.rawValue,
            BundledRelationKey.name.rawValue,
            BundledRelationKey.iconEmoji.rawValue,
            BundledRelationKey.description.rawValue,
            BundledRelationKey.isHidden.rawValue,
            BundledRelationKey.isReadonly.rawValue,
            BundledRelationKey.isArchived.rawValue,
            BundledRelationKey.smartblockTypes.rawValue,
            BundledRelationKey.sourceObject.rawValue,
            BundledRelationKey.recommendedRelations.rawValue
        ]

        return .search(
            SubscriptionData.Search(
                identifier: .objectType,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: keys
            )
        )
    }
}
