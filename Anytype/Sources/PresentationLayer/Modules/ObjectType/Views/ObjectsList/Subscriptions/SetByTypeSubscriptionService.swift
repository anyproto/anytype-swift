import Foundation
import Services
@preconcurrency import Combine
import AnytypeCore

protocol SetByTypeSubscriptionServiceProtocol: AnyObject, Sendable {
    func startSubscription(
        typeId: String,
        spaceId: String
    ) async -> AnyPublisher<ObjectDetails?, Never>
    func stopSubscription() async
}

actor SetByTypeSubscriptionService: SetByTypeSubscriptionServiceProtocol {
    private let subscriptionId = "SetByTypeSubscriptionService-\(UUID().uuidString)"
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    func startSubscription(
        typeId: String,
        spaceId: String
    ) async -> AnyPublisher<ObjectDetails?, Never> {
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.createdDate,
            type: .desc
        )
        let filters = [
            SearchHelper.layoutFilter([.set]),
            SearchHelper.setOfType(typeId: typeId)
        ]
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: subscriptionId,
                spaceId: spaceId,
                sorts: [sort],
                filters: filters,
                limit: 1,
                offset: 0,
                keys: BundledRelationKey.objectListKeys.map { $0.rawValue }
            )
        )
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: searchData)
        return subscriptionStorage.statePublisher.map { $0.items.first }.eraseToAnyPublisher()
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}
