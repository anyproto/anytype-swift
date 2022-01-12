import BlocksModels

enum SubscriptionUpdate {
    case initialData([ObjectDetails])
    case update(ObjectDetails)
    case remove(BlockId)
    case add(ObjectDetails, after: BlockId?)
    case move(from: BlockId, after: BlockId?)
}

typealias SubscriptionCallback = (SubscriptionId, SubscriptionUpdate) -> ()
protocol SubscriptionsServiceProtocol {
    func toggleSubscriptions(ids: [SubscriptionId], turnOn: Bool, update: @escaping SubscriptionCallback)
    func toggleSubscription(id: SubscriptionId, turnOn: Bool, update: @escaping SubscriptionCallback)
    
    func stopAllSubscriptions()
}

