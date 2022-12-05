import ProtobufMessages
import BlocksModels
import AnytypeCore

protocol SubscriptionTogglerProtocol {
    func startSubscription(data: SubscriptionData) -> SubscriptionTogglerResult?
    func stopSubscription(id: SubscriptionId)
}

final class SubscriptionToggler: SubscriptionTogglerProtocol {

    func startSubscription(data: SubscriptionData) -> SubscriptionTogglerResult? {
        switch data {
        case let .search(data):
            return makeSearchToggler(data: data)
        case let .objects(data):
            return makeObjectsToggler(data: data)
        }
    }
    
    func stopSubscription(id: SubscriptionId) {
        _ = Anytype_Rpc.Object.SearchUnsubscribe.Service.invoke(subIds: [id.value])
    }
    
    // MARK: - Private
    
    private func makeSearchToggler(data: SubscriptionData.Search) -> SubscriptionTogglerResult? {
        let result = Anytype_Rpc.Object.SearchSubscribe.Service
            .invoke(
                subID: data.identifier.value,
                filters: data.filters,
                sorts: data.sorts,
                limit: Int64(data.limit),
                offset: Int64(data.offset),
                keys: data.keys,
                afterID: data.afterID ?? "",
                beforeID: data.beforeID ?? "",
                source: data.source,
                ignoreWorkspace: data.ignoreWorkspace ?? "",
                noDepSubscription: data.noDepSubscription
            )
            .getValue(domain: .subscriptionService)
        
        guard let result = result else {
            return nil
        }
        
        return SubscriptionTogglerResult(
            records: result.records.asDetais,
            dependencies: result.dependencies.asDetais,
            count: Int(result.counters.total)
        )
    }
    
    private func makeObjectsToggler(data: SubscriptionData.Object) -> SubscriptionTogglerResult? {
        let result = Anytype_Rpc.Object.SubscribeIds.Service
            .invoke(
                subID: data.identifier.value,
                ids: data.objectIds,
                keys: data.keys,
                ignoreWorkspace: data.ignoreWorkspace ?? ""
            )
            .getValue(domain: .subscriptionService)
        
        guard let result = result else {
            return nil
        }

        return SubscriptionTogglerResult(
            records: result.records.asDetais,
            dependencies: result.dependencies.asDetais,
            count: data.objectIds.count
        )
    }
}
