import BlocksModels
import ProtobufMessages

final class GroupsSubscribeService: GroupsSubscribeServiceProtocol {
    
    func startSubscription(
        id: SubscriptionId,
        relationKey: String,
        filters: [DataviewFilter],
        source: [String]
    ) async throws -> GroupsSubscribeResult {
        let response = try await Anytype_Rpc.Object.GroupsSubscribe.Service
            .invocation(
                subID: id.value,
                relationKey: relationKey,
                filters: filters,
                source: source
            )
            .invoke(errorDomain: .groupsSubscribeService)
        return GroupsSubscribeResult(subscriptionId: response.subID, groups: response.groups)
    }
    
    func stopSubscription(id: SubscriptionId) {
        _ = Anytype_Rpc.Object.SearchUnsubscribe.Service.invoke(subIds: [id.value])
    }
}
