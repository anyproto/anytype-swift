import Foundation
import Services
import Combine
import AnytypeCore
import AsyncTools

protocol BinSubscriptionServiceProtocol: AnyObject, Sendable {
    func legacyStartSubscription(
        spaceId: String,
        objectLimit: Int?,
        update: @escaping @MainActor ([ObjectDetails]) -> Void
    )  async
    
    func startSubscription(spaceId: String, objectLimit: Int?) async -> AnyAsyncSequence<[ObjectDetails]>
    
    func stopSubscription() async
}

actor BinSubscriptionService: BinSubscriptionServiceProtocol {
    
    private enum Constants {
        static let limit = 100
    }
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    private let subscriptionId = "Bin-\(UUID().uuidString)"
    
    func legacyStartSubscription(
        spaceId: String,
        objectLimit: Int?,
        update: @escaping @MainActor ([ObjectDetails]) -> Void
    ) async {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters(isArchive: true)
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
    
    func startSubscription(spaceId: String, objectLimit: Int?) async -> AnyAsyncSequence<[ObjectDetails]> {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.lastModifiedDate,
            type: .desc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters(isArchive: true)
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
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData)
        
        return subscriptionStorage.statePublisher.map { $0.items }.values.eraseToAnyAsyncSequence()
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
