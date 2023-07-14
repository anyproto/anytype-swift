import Services
import ProtobufMessages

final class GroupsSubscribeService: GroupsSubscribeServiceProtocol {
    
    func startSubscription(
        id: SubscriptionId,
        relationKey: String,
        filters: [DataviewFilter],
        source: [String]?,
        collectionId: String?
    ) async throws -> GroupsSubscribeResult {
        let response = try await ClientCommands.objectGroupsSubscribe(.with {
            $0.subID = id.value
            $0.relationKey = relationKey
            $0.filters = filters
            $0.source = source ?? []
            $0.collectionID = collectionId ?? ""
        }).invoke()
        return GroupsSubscribeResult(subscriptionId: response.subID, groups: response.groups)
    }
    
    func stopSubscription(id: SubscriptionId) async throws {
        _ = try await ClientCommands.objectSearchUnsubscribe(.with {
            $0.subIds = [id.value]
        }).invoke()
    }
}
