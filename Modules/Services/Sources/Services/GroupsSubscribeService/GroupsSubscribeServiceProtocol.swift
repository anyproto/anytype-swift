public protocol GroupsSubscribeServiceProtocol {
    func startSubscription(
        id: String,
        relationKey: String,
        filters: [DataviewFilter],
        source: [String]?,
        collectionId: String?
    ) async throws -> GroupsSubscribeResult
    
    func stopSubscription(id: String) async throws
}
