import Foundation
import Services
@preconcurrency import Combine

protocol TreeSubscriptionManagerProtocol: AnyObject, Sendable {
    var detailsPublisher: AnyPublisher<[ObjectDetails], Never> { get }
    func startOrUpdateSubscription(spaceId: String, objectIds: [String]) async -> Bool
    func stopAllSubscriptions() async
}

actor TreeSubscriptionManager: TreeSubscriptionManagerProtocol {
    
    private let subscriptionDataBuilder: any TreeSubscriptionDataBuilderProtocol = Container.shared.treeSubscriptionDataBuilder()
    private let subscriptionStorageProvider: any SubscriptionStorageProviderProtocol = Container.shared.subscriptionStorageProvider()
    private let subscriptionStorage: any SubscriptionStorageProtocol
    
    private var objectIds: [String] = []
    private var subscriptionStarted: Bool = false
    private let detailsSubject = PassthroughSubject<[ObjectDetails], Never>()
    
    nonisolated let detailsPublisher: AnyPublisher<[ObjectDetails], Never>
    
    init() {
        subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionDataBuilder.subscriptionId)
        detailsPublisher = subscriptionStorage.statePublisher
            .map { $0.items }
            .merge(with: detailsSubject)
            .map { $0.filter(\.isNotDeletedAndSupportedForOpening) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - TreeSubscriptionDataBuilderProtocol
    
    func startOrUpdateSubscription(spaceId: String, objectIds newObjectIds: [String]) async -> Bool {
        let newObjectIdsSet = Set(newObjectIds)
        let objectIdsSet = Set(objectIds)
        guard objectIdsSet != newObjectIdsSet || !subscriptionStarted else { return false }
        
        objectIds = newObjectIds
        subscriptionStarted = true
        
        if newObjectIds.isEmpty {
            try? await subscriptionStorage.stopSubscription()
            detailsSubject.send([])
            return true
        }
        
        let subscriptionData = subscriptionDataBuilder.build(spaceId: spaceId, objectIds: objectIds)
        try? await subscriptionStorage.startOrUpdateSubscription(data: subscriptionData)
        return true
    }
    
    func stopAllSubscriptions() async {
        try? await subscriptionStorage.stopSubscription()
        objectIds.removeAll()
        subscriptionStarted = false
    }
}
