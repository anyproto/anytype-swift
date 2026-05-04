import AnytypeCore
import Foundation
import Services

@MainActor
protocol DateRelatedObjectsSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        spaceId: String,
        filters: [DataviewFilter],
        sort: DataviewSort,
        limit: Int,
        update: @escaping @MainActor ([ObjectDetails], Int) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class DateRelatedObjectsSubscriptionService: DateRelatedObjectsSubscriptionServiceProtocol {
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    private let subscriptionId = "DateRelatedObjects-\(UUID().uuidString)"
    
    nonisolated init() {}
    
    func startSubscription(
        spaceId: String,
        filters: [DataviewFilter],
        sort: DataviewSort,
        limit: Int,
        update: @escaping @MainActor ([ObjectDetails], Int) -> Void
    ) async {
        
        let spaceType = spaceViewsStorage.spaceView(spaceId: spaceId)?.spaceType
        let allFilters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, layouts: DetailsLayout.visibleLayoutsWithFiles(spaceType: spaceType), spaceType: spaceType)
            filters
        }
        
        let keys = BundledPropertyKey.objectListKeys.map { $0.rawValue } + [ BundledPropertyKey.origin.rawValue ]
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                spaceId: spaceId,
                sorts: [sort],
                filters: allFilters,
                limit: limit,
                offset: 0,
                keys: keys
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData) { data in
            await update(data.items, data.prevCount)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
