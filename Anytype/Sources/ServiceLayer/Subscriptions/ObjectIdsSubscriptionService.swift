import Foundation
import Services
import Combine
import AnytypeCore

protocol ObjectIdsSubscriptionServiceProtocol: AnyObject, Sendable  {
    func startSubscription(
        spaceId: String,
        objectIds: [String],
        additionalKeys: [BundledPropertyKey],
        update: @escaping @Sendable ([ObjectDetails]) async -> Void
    ) async
    func stopSubscription() async
}

actor ObjectIdsSubscriptionService: ObjectIdsSubscriptionServiceProtocol {
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: any SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionId)
    }()
    
    private let subscriptionId = "ObjectIdsSubscriptionService-\(UUID().uuidString)"
    
    func startSubscription(
        spaceId: String,
        objectIds: [String],
        additionalKeys: [BundledPropertyKey],
        update: @escaping @Sendable ([ObjectDetails]) async -> Void
    ) async {
        
        let keys: [BundledPropertyKey] = .builder {
            BundledPropertyKey.objectListKeys
            additionalKeys
        }.uniqued()
        
        let searchData: SubscriptionData = .objects(
            SubscriptionData.Object(
                identifier: subscriptionId,
                spaceId: spaceId,
                objectIds: objectIds,
                keys: keys.map { $0.rawValue }
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
