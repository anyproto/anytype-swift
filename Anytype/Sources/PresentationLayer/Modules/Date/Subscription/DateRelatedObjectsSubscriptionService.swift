import Foundation
import Services

@MainActor
protocol DateRelatedObjectsSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        objectId: String,
        spaceId: String,
        relationKey: String,
        limit: Int,
        update: @escaping ([ObjectDetails], Int) -> Void
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
        objectId: String,
        spaceId: String,
        relationKey: String,
        limit: Int,
        update: @escaping ([ObjectDetails], Int) -> Void
    ) async {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastOpenedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, layouts: DetailsLayout.visibleLayoutsWithFiles)
            relationFilter(key: relationKey, value: objectId)
        }
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                spaceId: spaceId,
                sorts: [sort],
                filters: filters,
                limit: limit,
                offset: 0,
                keys: BundledRelationKey.objectListKeys.map { $0.rawValue }
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData) { data in
            update(data.items, data.prevCount)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
    
    private func relationFilter(key: String, value: String) -> DataviewFilter {
        var filter = DataviewFilter()
        filter.condition = .in
        filter.value = value.protobufValue
        filter.relationKey = key
        
        return filter
    }
}
