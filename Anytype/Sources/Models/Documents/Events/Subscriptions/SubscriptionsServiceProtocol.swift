import Services

enum SubscriptionUpdate {
    case initialData([ObjectDetails])
    case update(ObjectDetails)
    case remove(BlockId)
    case add(ObjectDetails, after: BlockId?)
    case move(from: BlockId, after: BlockId?)
    case pageCount(Int)
    
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
    func hasSubscriptionDataDiff(with data: SubscriptionData) -> Bool
    
    func startSubscriptions(data: [SubscriptionData], update: @escaping SubscriptionCallback)
    func startSubscription(data: SubscriptionData, update: @escaping SubscriptionCallback)
    // Wait until subscription started and received initial data
    func startSubscriptionAsync(data: SubscriptionData, update: @escaping SubscriptionCallback) async
    
    func stopSubscriptions(ids: [SubscriptionId])
    func stopSubscription(id: SubscriptionId)
    func stopAllSubscriptions()
}
