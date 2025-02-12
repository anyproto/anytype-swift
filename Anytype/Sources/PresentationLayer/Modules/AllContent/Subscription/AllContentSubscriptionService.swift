import Foundation
import Services

@MainActor
protocol AllContentSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        spaceId: String,
        type: AllContentType,
        sort: AllContentSort,
        onlyUnlinked: Bool,
        limitedObjectsIds: [String]?,
        limit: Int,
        update: @escaping @MainActor ([ObjectDetails], Int) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class AllContentSubscriptionService: AllContentSubscriptionServiceProtocol {
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    private let subscriptionId = "AllContent-\(UUID().uuidString)"
    
    nonisolated init() {}
    
    func startSubscription(
        spaceId: String,
        type: AllContentType,
        sort: AllContentSort,
        onlyUnlinked: Bool,
        limitedObjectsIds: [String]?,
        limit: Int,
        update: @escaping @MainActor ([ObjectDetails], Int) -> Void
    ) async {
        
        let filters: [DataviewFilter] = .builder {
            SearchFiltersBuilder.build(isArchived: false, layouts: type.supportedLayouts)
            if onlyUnlinked {
                SearchHelper.onlyUnlinked()
            }
            if let limitedObjectsIds {
                SearchHelper.objectsIds(limitedObjectsIds)
            }
        }
        
        let sort = sort.asDataviewSort()
        let keys: [BundledRelationKey] = .builder {
            BundledRelationKey.createdDate
            BundledRelationKey.lastModifiedDate
            BundledRelationKey.objectListKeys
        }
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                spaceId: spaceId,
                sorts: [sort],
                filters: filters,
                limit: limit,
                offset: 0,
                keys: keys.map { $0.rawValue }
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
