import Foundation
import Services

final class PropertySubscriptionDataBuilder: MultispaceSubscriptionDataBuilderProtocol, MultispaceSearchDataBuilderProtocol {
    
    // MARK: - MultispaceSubscriptionDataBuilderProtocol
    
    func build(accountId: String, spaceId: String, subId: String) -> SubscriptionData {
        let sort = SearchHelper.sort(
            relation: BundledPropertyKey.name,
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
                keys: PropertyDetails.subscriptionKeys.map(\.rawValue),
                noDepSubscription: true
            )
        )
    }
    
    // MARK: - MultispaceSearchDataBuilderProtocol
    
    func buildSearch(spaceId: String) -> SearchRequest {
        let sort = SearchHelper.sort(
            relation: BundledPropertyKey.name,
            type: .asc
        )
        let filters = [
            SearchHelper.isArchivedFilter(isArchived: false),
            SearchHelper.layoutFilter([.relation])
        ]
        return SearchRequest(
            spaceId: spaceId,
            filters: filters,
            sorts: [sort],
            fullText: "",
            keys: PropertyDetails.subscriptionKeys.map(\.rawValue),
            limit: 0
        )
    }
}
