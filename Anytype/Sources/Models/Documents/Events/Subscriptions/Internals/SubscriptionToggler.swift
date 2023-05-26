import ProtobufMessages
import Services
import AnytypeCore

protocol SubscriptionTogglerProtocol {
    func startSubscription(data: SubscriptionData) async throws -> SubscriptionTogglerResult?
    func stopSubscription(id: SubscriptionId) async throws
    func stopSubscriptions(ids: [SubscriptionId]) async throws
}

final class SubscriptionToggler: SubscriptionTogglerProtocol {

    func startSubscription(data: SubscriptionData) async throws -> SubscriptionTogglerResult? {
        switch data {
        case let .search(data):
            return try await makeSearchToggler(data: data)
        case let .objects(data):
            return try await makeObjectsToggler(data: data)
        }
    }
    
    func stopSubscription(id: SubscriptionId) async throws {
        try await stopSubscriptions(ids: [id])
    }
    
    func stopSubscriptions(ids: [SubscriptionId]) async throws {
        try await ClientCommands.objectSearchUnsubscribe(.with {
            $0.subIds = ids.map { $0.value }
        }).invoke(errorDomain: .subscriptionService)
    }
    
    // MARK: - Private
    
    private func makeSearchToggler(data: SubscriptionData.Search) async throws -> SubscriptionTogglerResult {
        let result = try await ClientCommands.objectSearchSubscribe(.with {
            $0.subID = data.identifier.value
            $0.filters = data.filters
            $0.sorts = data.sorts
            $0.limit = Int64(data.limit)
            $0.offset = Int64(data.offset)
            $0.keys = data.keys
            $0.afterID = data.afterID ?? ""
            $0.beforeID = data.beforeID ?? ""
            $0.source = data.source ?? []
            $0.ignoreWorkspace = data.ignoreWorkspace ?? ""
            $0.noDepSubscription = data.noDepSubscription
            $0.collectionID = data.collectionId ?? ""
        }).invoke(errorDomain: .subscriptionService)
        
        return SubscriptionTogglerResult(
            records: result.records.asDetais,
            dependencies: result.dependencies.asDetais,
            count: Int(result.counters.total)
        )
    }
    
    private func makeObjectsToggler(data: SubscriptionData.Object) async throws -> SubscriptionTogglerResult? {
        let result = try await ClientCommands.objectSubscribeIds(.with {
            $0.subID = data.identifier.value
            $0.ids = data.objectIds
            $0.keys = data.keys
            $0.ignoreWorkspace = data.ignoreWorkspace ?? ""
        }).invoke(errorDomain: .subscriptionService)

        return SubscriptionTogglerResult(
            records: result.records.asDetais,
            dependencies: result.dependencies.asDetais,
            count: data.objectIds.count
        )
    }
}
