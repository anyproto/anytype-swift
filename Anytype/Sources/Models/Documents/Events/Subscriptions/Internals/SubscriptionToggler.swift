import ProtobufMessages
import BlocksModels
import AnytypeCore

protocol SubscriptionTogglerProtocol {
    func startSubscription(data: SubscriptionData) -> SubscriptionTogglerResult?
    func stopSubscription(id: SubscriptionId)
}

final class SubscriptionToggler: SubscriptionTogglerProtocol {
    let numberOfRowsPerPageInSubscriptions = UserDefaultsConfig.rowsPerPageInSet
    
    func startSubscription(data: SubscriptionData) -> SubscriptionTogglerResult? {
        switch data {
        case .search(let description):
            return makeSearchToggler(description: description)
        case .objects(let description):
            return makeObjectsToggler(description: description)
        }
    }
    
    func stopSubscription(id: SubscriptionId) {
        _ = Anytype_Rpc.Object.SearchUnsubscribe.Service.invoke(subIds: [id.value])
    }
    
    // MARK: - Private
    
    private func makeSearchToggler(description: SubscriptionDescriptionSearch) -> SubscriptionTogglerResult? {
        let result = Anytype_Rpc.Object.SearchSubscribe.Service
            .invoke(
                subID: description.identifier.value,
                filters: description.filters,
                sorts: description.sorts,
                limit: Int64(description.limit),
                offset: Int64(description.offset),
                keys: description.keys,
                afterID: description.afterID ?? "",
                beforeID: description.beforeID ?? "",
                source: description.source,
                ignoreWorkspace: description.ignoreWorkspace ?? "",
                noDepSubscription: description.noDepSubscription
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
    
    private func makeObjectsToggler(description: SubscriptionDescriptionObjects) -> SubscriptionTogglerResult? {
        let result = Anytype_Rpc.Object.SubscribeIds.Service
            .invoke(
                subID: description.identifier.value,
                ids: description.objectIds,
                keys: description.keys,
                ignoreWorkspace: description.ignoreWorkspace ?? ""
            )
            .getValue(domain: .subscriptionService)
        
        guard let result = result else {
            return nil
        }

        return SubscriptionTogglerResult(
            records: result.records.asDetais,
            dependencies: result.dependencies.asDetais,
            count: description.objectIds.count
        )
    }
}
