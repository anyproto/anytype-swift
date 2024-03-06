import Foundation
import Services

final class RelationSubscriptionDataBuilder: RelationSubscriptionDataBuilderProtocol {
    
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    
    // MARK: - RelationSubscriptionDataBuilderProtocol
    
    func build() -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        let filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.layoutFilter([.relation])
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
            BundledRelationKey.sourceObject.rawValue,
            BundledRelationKey.spaceId.rawValue
        ]
        
        return .search(
            SubscriptionData.Search(
                identifier: RelationDetailsStorage.subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: keys
            )
        )
    }
}
