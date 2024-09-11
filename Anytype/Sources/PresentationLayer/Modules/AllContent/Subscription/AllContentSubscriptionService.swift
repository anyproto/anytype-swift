import Foundation
import Services

@MainActor
protocol AllContentSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        spaceId: String,
        update: @escaping ([ObjectDetails]) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class AllContentSubscriptionService: AllContentSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    private let subscriptionId = "AllContent-\(UUID().uuidString)"
    
    nonisolated init() {}
    
    func startSubscription(
        spaceId: String,
        update: @escaping ([ObjectDetails]) -> Void
    ) async {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.spaceId(spaceId)
            SearchHelper.notHiddenFilters()
            SearchHelper.layoutFilter(DetailsLayout.visibleLayoutsWithFiles)
        }
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                sorts: [sort],
                filters: filters,
                limit: Constants.limit,
                offset: 0,
                keys: BundledRelationKey.objectListKeys.map { $0.rawValue }
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData) { data in
            update(data.items)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
