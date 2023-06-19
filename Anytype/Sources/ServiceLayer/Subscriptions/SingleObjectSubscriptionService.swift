import Foundation
import Services

protocol SingleObjectSubscriptionServiceProtocol: AnyObject {
    func startSubscription(subIdPrefix: String, objectId: String, dataHandler: @escaping (ObjectDetails) -> Void)
}

final class SingleObjectSubscriptionService: SingleObjectSubscriptionServiceProtocol {
    
    // MARK: - DI
    
    private let subscriptionService: SubscriptionsServiceProtocol
    private let subscriotionBuilder: ObjectsCommonSubscriptionDataBuilderProtocol
    
    private var cache = [String: [ObjectDetails]]()
    
    init(
        subscriptionService: SubscriptionsServiceProtocol,
        subscriotionBuilder: ObjectsCommonSubscriptionDataBuilderProtocol
    ) {
        self.subscriptionService = subscriptionService
        self.subscriotionBuilder = subscriotionBuilder
    }
    
    // MARK: - SingleObjectSubscriptionServiceProtocol
    
    func startSubscription(subIdPrefix: String, objectId: String, dataHandler: @escaping (ObjectDetails) -> Void) {
        let subData = subscriotionBuilder.build(subIdPrefix: subIdPrefix, objectIds: [objectId])
        subscriptionService.startSubscription(data: subData, update: { [weak self] subId, update in
            var details = self?.cache[subIdPrefix] ?? []
            details.applySubscriptionUpdate(update)
            self?.cache[subIdPrefix] = details
            guard let object = details.first else { return }
            dataHandler(object)
        })
    }
}
