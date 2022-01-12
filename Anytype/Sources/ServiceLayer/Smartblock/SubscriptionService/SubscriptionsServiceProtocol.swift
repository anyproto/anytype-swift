import BlocksModels

enum SubscriptionUpdate {
    case initialData([ObjectDetails])
    case update(ObjectDetails)
    case remove(BlockId)
    case add(ObjectDetails, after: BlockId?)
    case move(from: BlockId, after: BlockId?)
    
    var isInitialData: Bool {
        switch self {
        case .initialData:
            return true
        default:
            return false
        }
    }
}

typealias SubscriptionCallback = (SubscriptionId, SubscriptionUpdate) -> ()
protocol SubscriptionsServiceProtocol {
    func startSubscriptions(ids: [SubscriptionId], update: @escaping SubscriptionCallback)
    func startSubscription(id: SubscriptionId, update: @escaping SubscriptionCallback)
    
    func stopSubscriptions(ids: [SubscriptionId])
    func stopSubscription(id: SubscriptionId)
    func stopAllSubscriptions()
}

