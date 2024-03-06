import Foundation
import Services

protocol TreeSubscriptionManagerProtocol: AnyObject {
    var handler: ((_ child: [ObjectDetails]) -> Void)? { get set }
    func startOrUpdateSubscription(objectIds: [String]) async -> Bool
    func stopAllSubscriptions() async
}

final class TreeSubscriptionManager: TreeSubscriptionManagerProtocol {
    
    @Injected(\.treeSubscriptionDataBuilder)
    private var subscriptionDataBuilder: TreeSubscriptionDataBuilderProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: SubscriptionStorageProviderProtocol
    private lazy var subscriptionStorage: SubscriptionStorageProtocol = {
        subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionDataBuilder.subscriptionId)
    }()
    private var objectIds: [String] = []
    private var subscriptionStarted: Bool = false

    var handler: ((_ child: [ObjectDetails]) -> Void)?
    
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
