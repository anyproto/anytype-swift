import Services
import Combine
import AnytypeCore
import NotificationCenter

final class GroupsSubscriptionsHandler: GroupsSubscriptionsHandlerProtocol {
    
    private struct Subscriber {
        let data: GroupsSubscriptionData
        let callback: GroupsSubscriptionCallback
    }
    
    private var subscription: AnyCancellable?
    private let groupsSubscribeService: GroupsSubscribeServiceProtocol
    
    private var subscribers = SynchronizedDictionary<String, Subscriber>()
    
    init(groupsSubscribeService: GroupsSubscribeServiceProtocol) {
        self.groupsSubscribeService = groupsSubscribeService
        
        setup()
    }
    
    deinit {
        let keys = subscribers.keys
        Task { [keys, groupsSubscribeService] in
            await keys.asyncForEach { try? await groupsSubscribeService.stopSubscription(id: $0) }
        }
    }
    
    func startGroupsSubscription(data: GroupsSubscriptionData, update: @escaping GroupsSubscriptionCallback) async throws -> [DataviewGroup] {
        guard subscribers[data.identifier].isNil else {
            return []
        }
        
        subscribers[data.identifier] = Subscriber(data: data, callback: update)
        
        return try await groupsSubscribeService.startSubscription(
            id: data.identifier,
            relationKey: data.relationKey,
            filters: data.filters,
            source: data.source,
            collectionId: data.collectionId
        ).groups
    }
    
    func hasGroupsSubscriptionDataDiff(with data: GroupsSubscriptionData) -> Bool {
        guard let subscriber = subscribers[data.identifier] else {
            return true
        }
        return data != subscriber.data
    }
    
    func stopAllSubscriptions() async throws {
        try await subscribers.keys.asyncForEach { try await stopGroupsSubscription(id: $0) }
    }
 
    // MARK: - Private
    
    private func stopGroupsSubscription(id: String) async throws {
        guard subscribers[id].isNotNil else { return }

        _ = try await groupsSubscribeService.stopSubscription(id: id)
        subscribers[id] = nil
    }
    
    private func setup() {
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            guard events.contextId.isEmpty else { return }
            await self?.handle(events: events)
        }
    }
    
    private func handle(events: EventsBunch) async {
        // handle only Groups Subscription events
        for event in events.middlewareEvents {
            switch event.value {
            case .subscriptionGroups(let data):
                await sendUpdate(
                    subId: data.subID,
                    group: data.group,
                    remove: data.remove
                )
            default:
                break
            }
        }
    }
    
    private func sendUpdate(subId: String, group: DataviewGroup, remove: Bool) async {
        guard let action = subscribers[subId]?.callback else {
            return
        }
        await action(group, remove)
    }
}
