import ProtobufMessages

public protocol ObjectSubscriptionServiceProtocol {
    func objectSubscribe(data: SubscriptionData.Object) async throws -> ObjectSubscriptionResponse
    func objectSearchSubscribe(data: SubscriptionData.Search) async throws -> ObjectSubscriptionResponse
    func stopSubscriptions(ids: [String]) async throws
}

final class ObjectSubscriptionService: ObjectSubscriptionServiceProtocol {
    
    public func objectSubscribe(data: SubscriptionData.Object) async throws -> ObjectSubscriptionResponse {
        let result = try await ClientCommands.objectSubscribeIds(.with {
            $0.subID = data.identifier
            $0.ids = data.objectIds
            $0.keys = data.keys
            $0.ignoreWorkspace = data.ignoreWorkspace ?? ""
        }).invoke()
        return ObjectSubscriptionResponse(
            records: result.records.asDetais,
            dependencies: result.dependencies.asDetais,
            total: data.objectIds.count,
            prevCount: 0,
            nextCount: 0
        )
    }
    
    public func objectSearchSubscribe(data: SubscriptionData.Search) async throws -> ObjectSubscriptionResponse {
        let result = try await ClientCommands.objectSearchSubscribe(.with {
            $0.subID = data.identifier
            $0.filters = data.filters
            $0.sorts = data.sorts.map { $0.fixIncludeTime() }
            $0.limit = Int64(data.limit)
            $0.offset = Int64(data.offset)
            $0.keys = data.keys
            $0.afterID = data.afterID ?? ""
            $0.beforeID = data.beforeID ?? ""
            $0.source = data.source ?? []
            $0.ignoreWorkspace = data.ignoreWorkspace ?? ""
            $0.noDepSubscription = data.noDepSubscription
            $0.collectionID = data.collectionId ?? ""
        }).invoke()
        return ObjectSubscriptionResponse(
            records: result.records.asDetais,
            dependencies: result.dependencies.asDetais,
            total: Int(result.counters.total),
            prevCount: Int(result.counters.prevCount),
            nextCount: Int(result.counters.nextCount)
        )
    }
    
    public func stopSubscriptions(ids: [String]) async throws {
        try await ClientCommands.objectSearchUnsubscribe(.with {
            $0.subIds = ids
        }).invoke()
    }
}
