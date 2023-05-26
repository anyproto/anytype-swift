import Foundation
import Services

protocol TreeSubscriptionManagerProtocol: AnyObject {
    var handler: ((_ child: [ObjectDetails]) -> Void)? { get set }
    func startOrUpdateSubscription(objectIds: [String]) -> Bool
    func stopAllSubscriptions()
}

final class TreeSubscriptionManager: TreeSubscriptionManagerProtocol {
    
    private let subscriptionDataBuilder: TreeSubscriptionDataBuilderProtocol
    private let subscriptionService: SubscriptionsServiceProtocol
    private var objectIds: [String] = []
    private var data: [ObjectDetails] = []
    private var subscriptionStarted: Bool = false

    var handler: ((_ child: [ObjectDetails]) -> Void)?
    
    init(
        subscriptionDataBuilder: TreeSubscriptionDataBuilderProtocol,
        subscriptionService: SubscriptionsServiceProtocol
    ) {
        self.subscriptionDataBuilder = subscriptionDataBuilder
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - TreeSubscriptionDataBuilderProtocol
        
    func startOrUpdateSubscription(objectIds newObjectIds: [String]) -> Bool {
        let newObjectIdsSet = Set(newObjectIds)
        let objectIdsSet = Set(objectIds)
        guard objectIdsSet != newObjectIdsSet || !subscriptionStarted else { return false }
        
        objectIds = newObjectIds
        subscriptionStarted = true
        
        if newObjectIds.isEmpty {
            subscriptionService.stopAllSubscriptions()
            data.removeAll()
            handler?([])
            return true
        }
        
        let subscriptionData = subscriptionDataBuilder.build(objectIds: objectIds)
        subscriptionService.startSubscription(data: subscriptionData) { [weak self] subId, update in
            self?.handleEvent(subId: subId, update: update)
        }
        return true
    }
    
    func stopAllSubscriptions() {
        subscriptionService.stopAllSubscriptions()
        data.removeAll()
        objectIds.removeAll()
        subscriptionStarted = false
    }
    
    // MARK: - Private
    
    private func handleEvent(subId: SubscriptionId, update: SubscriptionUpdate) {
        data.applySubscriptionUpdate(update)
        let result = data.filter(\.isVisibleForEdit)
        handler?(result)
    }
}
