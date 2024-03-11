import Services

typealias GroupsSubscriptionCallback = @MainActor (_ group: DataviewGroup, _ remove: Bool) async -> ()

protocol GroupsSubscriptionsHandlerProtocol {
    func hasGroupsSubscriptionDataDiff(with data: GroupsSubscriptionData) -> Bool
    func startGroupsSubscription(data: GroupsSubscriptionData, update: @escaping GroupsSubscriptionCallback) async throws -> [DataviewGroup]
    func stopAllSubscriptions() async throws
}
