import BlocksModels

protocol GroupsSubscribeServiceProtocol {
    func startSubscription(
        id: SubscriptionId,
        relationKey: String,
        filters: [DataviewFilter],
        source: [String]
    ) async throws -> GroupsSubscribeResult
    
    func stopSubscription(id: SubscriptionId)
}
