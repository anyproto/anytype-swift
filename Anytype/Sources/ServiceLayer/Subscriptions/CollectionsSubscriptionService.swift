import Foundation
import Services
import Combine
import AnytypeCore

@MainActor
protocol CollectionsSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        spaceId: String,
        objectLimit: Int?,
        update: @escaping @MainActor ([ObjectDetails]) -> Void
    ) async
    func stopSubscription() async
}

@MainActor
final class CollectionsSubscriptionService: CollectionsSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    private let subscriptionId = "Collections-\(UUID().uuidString)"
    
    nonisolated init() {}
    
    func startSubscription(
        spaceId: String,
        objectLimit: Int?,
        update: @escaping @MainActor ([ObjectDetails]) -> Void
    ) async {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters()
            SearchHelper.layoutFilter([DetailsLayout.collection])
        }
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                spaceId: spaceId,
                sorts: [sort],
                filters: filters,
                limit: objectLimit ?? Constants.limit,
                offset: 0,
                keys: BundledRelationKey.objectListKeys.map { $0.rawValue }
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData) { data in
            await update(data.items)
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
