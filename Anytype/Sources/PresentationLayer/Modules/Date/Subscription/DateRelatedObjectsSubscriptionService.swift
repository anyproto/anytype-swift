import Foundation
import Services

@MainActor
protocol DateRelatedObjectsSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        spaceId: String,
        filters: [DataviewFilter],
        sort: DataviewSort,
        limit: Int,
        update: @escaping @Sendable @MainActor ([ObjectDetails], Int) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class DateRelatedObjectsSubscriptionService: DateRelatedObjectsSubscriptionServiceProtocol {
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
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
        update: @escaping @Sendable @MainActor ([ObjectDetails], Int) -> Void
    ) async {
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, layouts: DetailsLayout.visibleLayoutsWithFiles)
            filters
        }
        
        let keys = BundledRelationKey.objectListKeys.map { $0.rawValue } + [ BundledRelationKey.origin.rawValue ]
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                spaceId: spaceId,
                sorts: [sort],
                filters: filters,
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
