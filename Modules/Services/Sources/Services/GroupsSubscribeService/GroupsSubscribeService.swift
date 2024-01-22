import ProtobufMessages

public final class GroupsSubscribeService: GroupsSubscribeServiceProtocol {
    
    public init() {}
    
    public func startSubscription(
        id: String,
        relationKey: String,
        filters: [DataviewFilter],
        source: [String]?,
        collectionId: String?
    ) async throws -> GroupsSubscribeResult {
        let response = try await ClientCommands.objectGroupsSubscribe(.with {
            $0.subID = id
            $0.relationKey = relationKey
            $0.filters = filters
            $0.source = source ?? []
            $0.collectionID = collectionId ?? ""
        }).invoke()
        return GroupsSubscribeResult(subscriptionId: response.subID, groups: response.groups)
    }
    
    public func stopSubscription(id: String) async throws {
        _ = try await ClientCommands.objectSearchUnsubscribe(.with {
            $0.subIds = [id]
        }).invoke()
    }
}
