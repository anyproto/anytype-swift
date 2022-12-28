import Foundation
import BlocksModels

protocol ObjectTreeSubscriptionManagerProtocol: AnyObject {
    var handler: ((_ child: [ObjectDetails]) -> Void)? { get set }
    func startOrUpdateSubscription(objectIds: [String])
    func stopAllSubscriptions()
}

final class ObjectTreeSubscriptionManager: ObjectTreeSubscriptionManagerProtocol {
    
    private let subscriptionDataBuilder: ObjectTreeSubscriptionDataBuilderProtocol
    private let subscriptionService: SubscriptionsServiceProtocol
    private var objectIds: [String] = []
    private var data: [ObjectDetails] = []

    var handler: ((_ child: [ObjectDetails]) -> Void)?
    
    init(
        subscriptionDataBuilder: ObjectTreeSubscriptionDataBuilderProtocol,
        subscriptionService: SubscriptionsServiceProtocol
    ) {
        self.subscriptionDataBuilder = subscriptionDataBuilder
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - ObjectTreeSubscriptionManagerProtocol
        
    func startOrUpdateSubscription(objectIds newObjectIds: [String]) {
        let newObjectIdsSet = Set(newObjectIds)
        let objectIdsSet = Set(objectIds)
        guard objectIdsSet != newObjectIdsSet else { return }
        
        stopAllSubscriptions()
        
        objectIds = newObjectIds
        
        let subscriptionData = subscriptionDataBuilder.build(objectIds: objectIds)
        subscriptionService.startSubscription(data: subscriptionData) { [weak self] subId, update in
            self?.handleEvent(subId: subId, update: update)
        }
    }
    
    func stopAllSubscriptions() {
        subscriptionService.stopAllSubscriptions()
        data.removeAll()
        objectIds.removeAll()
    }
    
    
    // MARK: - Private
    
    private func handleEvent(subId: SubscriptionId, update: SubscriptionUpdate) {
        data.applySubscriptionUpdate(update)
        handler?(data)
    }
}
