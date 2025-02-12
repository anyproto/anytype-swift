import Services

typealias GroupsSubscriptionCallback = @Sendable @MainActor (_ group: DataviewGroup, _ remove: Bool) async -> ()

protocol GroupsSubscriptionsHandlerProtocol: Sendable {
    func hasGroupsSubscriptionDataDiff(with data: GroupsSubscriptionData) async -> Bool
    func startGroupsSubscription(data: GroupsSubscriptionData, update: @escaping GroupsSubscriptionCallback) async throws -> [DataviewGroup]
    func stopAllSubscriptions() async throws
}
