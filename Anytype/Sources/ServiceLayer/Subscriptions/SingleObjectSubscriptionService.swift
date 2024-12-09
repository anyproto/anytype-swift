import Foundation
import Services
import AnytypeCore

protocol SingleObjectSubscriptionServiceProtocol: AnyObject, Sendable {
    func startSubscription(
        subId: String,
        spaceId: String,
        objectId: String,
        additionalKeys: [BundledRelationKey],
        dataHandler: @escaping @Sendable (ObjectDetails) async -> Void
    ) async
    func stopSubscription(subId: String) async
}

extension SingleObjectSubscriptionServiceProtocol {
    func startSubscription(subId: String, spaceId: String, objectId: String, dataHandler: @escaping @Sendable (ObjectDetails) async -> Void) async {
        await self.startSubscription(subId: subId, spaceId: spaceId, objectId: objectId, additionalKeys: [], dataHandler: dataHandler)
    }
}

actor SingleObjectSubscriptionService: SingleObjectSubscriptionServiceProtocol {
    
    // MARK: - DI
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.objectsCommonSubscriptionDataBuilder)
    private var subscriptionBuilder: any ObjectsCommonSubscriptionDataBuilderProtocol
    
    private var subscriptionStorages: [String: any SubscriptionStorageProtocol] = [:]
    
    // MARK: - SingleObjectSubscriptionServiceProtocol
    
    func startSubscription(
        subId: String,
        spaceId: String,
        objectId: String,
        additionalKeys: [BundledRelationKey],
        dataHandler: @escaping @Sendable (ObjectDetails) async -> Void
    ) async {
        let subData = subscriptionBuilder.build(subId: subId, spaceId: spaceId, objectIds: [objectId], additionalKeys: additionalKeys)
    
        if subscriptionStorages[subId].isNotNil {
            anytypeAssertionFailure("Subscription already started", info: ["sub id": subId])
        }
        
        let subscriptionStorage = subscriptionStorages[subId] ?? subscriptionStorageProvider.createSubscriptionStorage(subId: subId)
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: subData) { data in
            guard let item = data.items.first else { return }
            await dataHandler(item)
        }
        
        subscriptionStorages[subId] = subscriptionStorage
    }
    
    func stopSubscription(subId: String) async {
        
        guard let subscriptionStorage = subscriptionStorages[subId] else {
            anytypeAssertionFailure("Subscription is not started", info: ["sub id": subId])
            return
        }
        
        subscriptionStorages[subId] = nil
        try? await subscriptionStorage.stopSubscription()
    }
}
