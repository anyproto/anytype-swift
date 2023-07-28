import Foundation
import Services

extension SubscriptionId {
    static var relation = SubscriptionId(value: "SubscriptionId.Relation")
}

final class RelationSubscriptionDataBuilder: RelationSubscriptionDataBuilderProtocol {
    
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
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.layoutFilter([.relation]),
//            SearchHelper.spaceId(accountManager.account.info.accountSpaceId)
        ]
        
        let keys = [
            BundledRelationKey.id.rawValue,
            BundledRelationKey.relationKey.rawValue,
            BundledRelationKey.name.rawValue,
            BundledRelationKey.relationFormat.rawValue,
            BundledRelationKey.relationReadonlyValue.rawValue,
            BundledRelationKey.relationFormatObjectTypes.rawValue,
            BundledRelationKey.isHidden.rawValue,
            BundledRelationKey.isReadonly.rawValue,
            BundledRelationKey.relationMaxCount.rawValue,
            BundledRelationKey.sourceObject.rawValue
        ]
        
        return .search(
            SubscriptionData.Search(
                identifier: .relation,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: keys
            )
        )
    }
}
