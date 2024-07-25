import Foundation
import Services
import Combine

protocol ActiveSpaceParticipantStorageProtocol: AnyObject {
    func participantsStream(spaceId: String) -> AsyncStream<[Participant]>
}

extension ActiveSpaceParticipantStorageProtocol {
    func activeParticipantsStream(spaceId: String) -> AsyncStream<[Participant]> {
        var iterator = participantsStream(spaceId: spaceId).map { $0.filter { $0.status == .active } }.makeAsyncIterator()
        return AsyncStream(unfolding: { await iterator.next() })
    }
}

actor ActiveSpaceParticipantStorage: ActiveSpaceParticipantStorageProtocol {
    
    // MARK: - DI
    
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    
    private var subscriptions: [String: SubscriptionStorageProtocol] = [:]
    private var clients: [String: Int] = [:]

    init() {}
    
    nonisolated func participantsStream(spaceId: String) -> AsyncStream<[Participant]> {
        AsyncStream { continuation in
            Task {
                let subscriptionStorage = await storageForClient(spaceId: spaceId)
                
                let cancellation = subscriptionStorage.statePublisher
                    .map { $0.items.compactMap { try? Participant(details: $0) } }
                    .sink { continuation.yield($0) }
                
                continuation.onTermination = { @Sendable [weak self] _ in
                    cancellation.cancel()
                    Task { [weak self] in
                        try await self?.removeClient(spaceId: spaceId)
                    }
                }
                
                try await startOrUpdateSubscription(spaceId: spaceId, subscriptionStorage: subscriptionStorage)
            }
        }
    }
    
    // MARK: - Private
    
    private func storageForClient(spaceId: String) -> SubscriptionStorageProtocol {
        let subscriptionStorage = subscriptions[spaceId] ?? subscriptionStorageProvider.createSubscriptionStorage(subId: makeSubId(spaceId: spaceId))
        subscriptions[spaceId] = subscriptionStorage
        let currentClients = clients[spaceId] ?? 0
        clients[spaceId] = currentClients + 1
        return subscriptionStorage
    }
    
    private func removeClient(spaceId: String) async throws {
        let currentClients = clients[spaceId] ?? 0
        if currentClients > 0 {
            clients[spaceId] = currentClients - 1
        } else {
            clients.removeValue(forKey: spaceId)
            subscriptions.removeValue(forKey: spaceId)
            try await subscriptions[spaceId]?.stopSubscription()
        }
    }
    
    private func startOrUpdateSubscription(spaceId: String, subscriptionStorage: SubscriptionStorageProtocol) async throws {
        
        let sort = SearchHelper.sort(
            relation: BundledRelationKey.name,
            type: .asc
        )
        
        let filters: [DataviewFilter] = .builder {
            SearchHelper.notHiddenFilters(includeHiddenDiscovery: false)
            SearchHelper.spaceId(spaceId)
            SearchHelper.layoutFilter([.participant])
            SearchHelper.participantStatusFilter(.active, .joining, .removing)
        }
        
        let searchData: SubscriptionData = .search(
            SubscriptionData.Search(
                identifier: "ActiveSpaceParticipant-\(spaceId)",
                sorts: [sort],
                filters: filters,
                limit: 0,
                offset: 0,
                keys: Participant.subscriptionKeys.map { $0.rawValue }
            )
        )
        
        try await subscriptionStorage.startOrUpdateSubscription(data: searchData)
    }
    
    private func makeSubId(spaceId: String) -> String {
        return "ActiveSpaceParticipant-\(spaceId)"
    }
}
