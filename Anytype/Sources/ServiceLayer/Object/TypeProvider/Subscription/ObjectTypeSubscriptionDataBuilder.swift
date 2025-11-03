import Foundation
import Services

final class ObjectTypeSubscriptionDataBuilder: MultispaceOneActiveSubscriptionDataBuilder {
    
    private let workspaceStorage: any SpaceViewsStorageProtocol = Container.shared.spaceViewsStorage()
    
    // MARK: - MultispaceOneActiveSubscriptionDataBuilder
    
    func build(accountId: String, spaceId: String, subId: String) -> SubscriptionData {
        
        let filters = [
            SearchHelper.layoutFilter([DetailsLayout.objectType])
        ]

        let spaceUxType = workspaceStorage.spaceView(spaceId: spaceId)?.uxType
        return .search(
            SubscriptionData.Search(
                identifier: subId,
                spaceId: spaceId,
                sorts: SearchHelper.defaultObjectTypeSort(spaceUxType: spaceUxType),
                filters: filters,
                limit: 0,
                offset: 0,
                keys: ObjectType.subscriptionKeys.map(\.rawValue),
                noDepSubscription: true
            )
        )
    }
    
    func buildSearch(spaceId: String) -> SearchRequest {
        let sort = SearchHelper.sort(
            relation: BundledPropertyKey.name,
            type: .asc
        )
        let filters = [
            SearchHelper.layoutFilter([DetailsLayout.objectType])
        ]
        return SearchRequest(
            spaceId: spaceId,
            filters: filters,
            sorts: [sort],
            fullText: "",
            keys: ObjectType.subscriptionKeys.map(\.rawValue),
            limit: 0
        )
    }
}
