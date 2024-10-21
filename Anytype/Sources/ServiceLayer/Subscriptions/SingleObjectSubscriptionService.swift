import Foundation
import Services
import AnytypeCore

protocol SingleObjectSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        subId: String,
        spaceId: String,
        objectId: String,
        additionalKeys: [BundledRelationKey],
        dataHandler: @escaping (ObjectDetails) -> Void
    ) async
    func stopSubscription(subId: String) async
}

extension SingleObjectSubscriptionServiceProtocol {
    func startSubscription(subId: String, spaceId: String, objectId: String, dataHandler: @escaping (ObjectDetails) -> Void) async {
        await self.startSubscription(subId: subId, spaceId: spaceId, objectId: objectId, additionalKeys: [], dataHandler: dataHandler)
    }
}

actor SingleObjectSubscriptionService: SingleObjectSubscriptionServiceProtocol {
    
    // MARK: - DI
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.objectsCommonSubscriptionDataBuilder)
    private var subscriptionBuilder: any ObjectsCommonSubscriptionDataBuilderProtocol
    
    private var subscriptionStoragess: [String: any SubscriptionStorageProtocol] = [:]
    
    // MARK: - SingleObjectSubscriptionServiceProtocol
    
    func startSubscription(
        subId: String,
        spaceId: String,
        objectId: String,
        additionalKeys: [BundledRelationKey],
        dataHandler: @escaping (ObjectDetails) -> Void
    ) async {
        let subData = subscriptionBuilder.build(subId: subId, spaceId: spaceId, objectIds: [objectId], additionalKeys: additionalKeys)
    
        if subscriptionStoragess[subId].isNotNil {
            anytypeAssertionFailure("Subscription already started", info: ["sub id": subId])
        }
        
        let subscriptionStorage = subscriptionStoragess[subId] ?? subscriptionStorageProvider.createSubscriptionStorage(subId: subId)
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: subData) { data in
            guard let item = data.items.first else { return }
            dataHandler(item)
        }
        
        subscriptionStoragess[subId] = subscriptionStorage
    }
    
    func stopSubscription(subId: String) async {
        
        guard let subscriptionStorages = subscriptionStoragess[subId] else {
            anytypeAssertionFailure("Subscription is not started", info: ["sub id": subId])
            return
        }
        
        subscriptionStoragess[subId] = nil
        try? await subscriptionStorages.stopSubscription()
    }
}
