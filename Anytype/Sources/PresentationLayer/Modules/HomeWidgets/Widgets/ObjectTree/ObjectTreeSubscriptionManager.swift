import Foundation
import BlocksModels

protocol ObjectTreeSubscriptionManagerProtocol: AnyObject {
    var handler: ((_ child: [ObjectDetails]) -> Void)? { get set }
    func startSubscription(objectIds: [String])
    func stopAllSubscriptions()
}

final class ObjectTreeSubscriptionManager: ObjectTreeSubscriptionManagerProtocol {
    
//    private struct ObjectTreeSubscription {
//        var objectId: String
//        var child: [ObjectDetails]
//    }
    
    private let subscriptionDataBuilder: ObjectTreeSubscriptionDataBuilderProtocol
    private let subscriptionService: SubscriptionsServiceProtocol
    private var data: [ObjectDetails] = []
//    private var subscriptions: [SubscriptionId: ObjectTreeSubscription] = [:]
    
    var handler: ((_ child: [ObjectDetails]) -> Void)?
    
    init(
        subscriptionDataBuilder: ObjectTreeSubscriptionDataBuilderProtocol,
        subscriptionService: SubscriptionsServiceProtocol
    ) {
        self.subscriptionDataBuilder = subscriptionDataBuilder
        self.subscriptionService = subscriptionService
    }
    
    // MARK: - ObjectTreeSubscriptionManagerProtocol
        
    func startSubscription(objectIds: [String]) {
        subscriptionService.stopAllSubscriptions()
        
        let subscriptionData = subscriptionDataBuilder.build(objectIds: objectIds)
//
//        guard !subscriptions.keys.contains(subscriptionData.identifier) else { return }
//
//        let subscription = ObjectTreeSubscription(
//            objectId: objectId,
//            child: []
//        )
//        subscriptions[subscriptionData.identifier] = subscription
//
        subscriptionService.startSubscription(data: subscriptionData) { [weak self] subId, update in
            self?.handleEvent(subId: subId, update: update)
        }
    }
    
    func stopAllSubscriptions() {
        subscriptionService.stopAllSubscriptions()
//        subscriptions.removeAll()
    }
    
    // MARK: - Private
    
    private func handleEvent(subId: SubscriptionId, update: SubscriptionUpdate) {
//        guard var subscription = subscriptions[subId] else { return }
        
//        subscription.child.applySubscriptionUpdate(update)
//        subscriptions[subId] = subscription
        
        data.applySubscriptionUpdate(update)
        
        handler?(data)
    }
}
