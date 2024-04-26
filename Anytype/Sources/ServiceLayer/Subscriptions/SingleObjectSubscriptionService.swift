import Foundation
import Services
import AnytypeCore

protocol SingleObjectSubscriptionServiceProtocol: AnyObject {
    func startSubscription(
        subId: String,
        objectId: String,
        additionalKeys: [BundledRelationKey],
        dataHandler: @escaping (ObjectDetails) -> Void
    ) async
    func stopSubscription(subId: String) async
}

extension SingleObjectSubscriptionServiceProtocol {
    func startSubscription(subId: String, objectId: String, dataHandler: @escaping (ObjectDetails) -> Void) async {
        await self.startSubscription(subId: subId, objectId: objectId, additionalKeys: [], dataHandler: dataHandler)
    }
}

actor SingleObjectSubscriptionService: SingleObjectSubscriptionServiceProtocol {
    
    // MARK: - DI
    
    private let subscriptionStorageProvider: SubscriptionStorageProviderProtocol
    private let subscriotionBuilder: ObjectsCommonSubscriptionDataBuilderProtocol
    
    private var subsctipyionStorages: [String: SubscriptionStorageProtocol] = [:]
    
    init(
        subscriptionStorageProvider: SubscriptionStorageProviderProtocol,
        subscriotionBuilder: ObjectsCommonSubscriptionDataBuilderProtocol
    ) {
        self.subscriptionStorageProvider = subscriptionStorageProvider
        self.subscriotionBuilder = subscriotionBuilder
    }
    
    // MARK: - SingleObjectSubscriptionServiceProtocol
    
    func startSubscription(
        subId: String,
        objectId: String,
        additionalKeys: [BundledRelationKey],
        dataHandler: @escaping (ObjectDetails) -> Void
    ) async {
        let subData = subscriotionBuilder.build(subId: subId, objectIds: [objectId], additionalKeys: additionalKeys)
    
        if subsctipyionStorages[subId].isNotNil {
            anytypeAssertionFailure("Subscription already started", info: ["sub id": subId])
        }
        
        let subscriptionStorage = subsctipyionStorages[subId] ?? subscriptionStorageProvider.createSubscriptionStorage(subId: subId)
        
        try? await subscriptionStorage.startOrUpdateSubscription(data: subData) { data in
            guard let item = data.items.first else { return }
            dataHandler(item)
        }
        
        subsctipyionStorages[subId] = subscriptionStorage
    }
    
    func stopSubscription(subId: String) async {
        
        guard let subsctipyionStorage = subsctipyionStorages[subId] else {
            anytypeAssertionFailure("Subscription is not started", info: ["sub id": subId])
            return
        }
        
        subsctipyionStorages[subId] = nil
        try? await subsctipyionStorage.stopSubscription()
    }
}
