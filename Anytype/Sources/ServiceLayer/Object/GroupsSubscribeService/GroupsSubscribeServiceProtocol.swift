import Services

protocol GroupsSubscribeServiceProtocol {
    func startSubscription(
        id: SubscriptionId,
        relationKey: String,
        filters: [DataviewFilter],
        source: [String]?,
        collectionId: String?
    ) async throws -> GroupsSubscribeResult
    
    func stopSubscription(id: SubscriptionId)
}
