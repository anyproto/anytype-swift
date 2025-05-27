import ProtobufMessages
import Services
import AnytypeCore

protocol SubscriptionTogglerProtocol: Sendable {
    func startSubscription(data: SubscriptionData) async throws -> SubscriptionTogglerResult
    func stopSubscription(id: String) async throws
    func stopSubscriptions(ids: [String]) async throws
}

final class SubscriptionToggler: SubscriptionTogglerProtocol {
    
    private let objectSubscriptionService: any ObjectSubscriptionServiceProtocol = Container.shared.objectSubscriptionService()
    private let userDefaults: any UserDefaultsStorageProtocol = Container.shared.userDefaultsStorage()
    private let basicUserInfoStorage: any BasicUserInfoStorageProtocol = Container.shared.basicUserInfoStorage()
    
    func startSubscription(data: SubscriptionData) async throws -> SubscriptionTogglerResult {
        switch data {
        case let .search(data):
            return try await makeSearchToggler(data: data)
        case let .objects(data):
            return try await makeObjectsToggler(data: data)
        }
    }
    
    func stopSubscription(id: String) async throws {
        try await stopSubscriptions(ids: [id])
    }
    
    func stopSubscriptions(ids: [String]) async throws {
        guard basicUserInfoStorage.usersId.isNotEmpty else { return }
        try await objectSubscriptionService.stopSubscriptions(ids: ids)
    }
    
    // MARK: - Private
    
    private func makeSearchToggler(data: SubscriptionData.Search) async throws -> SubscriptionTogglerResult {
        let response = try await objectSubscriptionService.objectSearchSubscribe(data: data)
        
        return SubscriptionTogglerResult(
            records: response.records,
            dependencies: response.dependencies,
            total: response.total,
            prevCount: response.prevCount,
            nextCount: response.nextCount
        )
    }
    
    private func makeObjectsToggler(data: SubscriptionData.Object) async throws -> SubscriptionTogglerResult {
        let response = try await objectSubscriptionService.objectSubscribe(data: data)
        
        return SubscriptionTogglerResult(
            records: response.records,
            dependencies: response.dependencies,
            total: response.total,
            prevCount: response.prevCount,
            nextCount: response.nextCount
        )
    }
}
