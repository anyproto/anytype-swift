import Foundation
import Services
@preconcurrency import Combine
import AnytypeCore

protocol ObjectsListSubscriptionServiceProtocol: AnyObject, Sendable {
    func startSubscription(
        objectTypeId: String,
        spaceId: String,
        sort: AllContentSort
    ) async -> AnyPublisher<SubscriptionStorageState, Never>
    func stopSubscription() async
}

actor ObjectsListSubscriptionService: ObjectsListSubscriptionServiceProtocol {
    private let subscriptionId = "ObjectsListSubscriptionService-\(UUID().uuidString)"
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    func startSubscription(
        objectTypeId: String,
        spaceId: String,
        sort: AllContentSort
    ) async -> AnyPublisher<SubscriptionStorageState, Never>{
        let sort = SearchHelper.sort(
            relation: sort.relation.key,
            type: sort.type
        )
        let filters: [DataviewFilter] = .builder {
            SearchHelper.typeFilter([objectTypeId])
            SearchHelper.notHiddenFilters()
        }
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
                limit: 20,
                offset: 0,
                keys: keys.map { $0.rawValue }
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData)
        return subscriptionStorage.statePublisher
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
