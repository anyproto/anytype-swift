import Foundation
import Services

protocol TreeSubscriptionManagerProtocol: AnyObject {
    var handler: ((_ child: [ObjectDetails]) -> Void)? { get set }
    func startOrUpdateSubscription(objectIds: [String]) async -> Bool
    func stopAllSubscriptions() async
}

final class TreeSubscriptionManager: TreeSubscriptionManagerProtocol {
    
    private let subscriptionDataBuilder: TreeSubscriptionDataBuilderProtocol
    private let subscriptionStorage: SubscriptionStorageProtocol
    private var objectIds: [String] = []
    private var subscriptionStarted: Bool = false

    var handler: ((_ child: [ObjectDetails]) -> Void)?
    
    init(
        subscriptionDataBuilder: TreeSubscriptionDataBuilderProtocol,
        subscriptionStorageProvider: SubscriptionStorageProviderProtocol
    ) {
        self.subscriptionDataBuilder = subscriptionDataBuilder
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionDataBuilder.subscriptionId)
    }
    
    // MARK: - TreeSubscriptionDataBuilderProtocol
        
    func startOrUpdateSubscription(objectIds newObjectIds: [String]) async -> Bool {
        let newObjectIdsSet = Set(newObjectIds)
        let objectIdsSet = Set(objectIds)
        guard objectIdsSet != newObjectIdsSet || !subscriptionStarted else { return false }
        
        objectIds = newObjectIds
        subscriptionStarted = true
        
        if newObjectIds.isEmpty {
            try? await subscriptionStorage.stopSubscription()
            handler?([])
            return true
        }
        
        let subscriptionData = subscriptionDataBuilder.build(objectIds: objectIds)
        try? await subscriptionStorage.startOrUpdateSubscription(data: subscriptionData) { [weak self] data in
            self?.handleStorage(data: data)
        }
        return true
    }
    
    func stopAllSubscriptions() async {
        try? await subscriptionStorage.stopSubscription()
        objectIds.removeAll()
        subscriptionStarted = false
    }
    
    // MARK: - Private
    
    private func handleStorage(data: SubscriptionStorageState) {
        let result = data.items.filter(\.isNotDeletedAndSupportedForEdit)
        handler?(result)
    }
}
