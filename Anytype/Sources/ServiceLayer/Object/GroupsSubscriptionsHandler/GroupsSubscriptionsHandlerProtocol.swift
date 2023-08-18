import Services

typealias GroupsSubscriptionCallback = (_ group: DataviewGroup, _ remove: Bool) -> ()

protocol GroupsSubscriptionsHandlerProtocol {
    func hasGroupsSubscriptionDataDiff(with data: GroupsSubscription) -> Bool
    func startGroupsSubscription(data: GroupsSubscription, update: @escaping GroupsSubscriptionCallback) async throws -> [DataviewGroup]
    func stopAllSubscriptions() async throws
}
