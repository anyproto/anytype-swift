import BlocksModels
import Combine
import AnytypeCore
import NotificationCenter

final class GroupsSubscriptionsHandler: GroupsSubscriptionsHandlerProtocol {
    
    private struct Subscriber {
        let data: GroupsSubscription
        let callback: GroupsSubscriptionCallback
    }
    
    private var subscription: AnyCancellable?
    private let groupsSubscribeService: GroupsSubscribeServiceProtocol
    
    private var subscribers = [SubscriptionId: Subscriber]()
    
    init(groupsSubscribeService: GroupsSubscribeServiceProtocol) {
        self.groupsSubscribeService = groupsSubscribeService
        
        setup()
    }
    
    deinit {
        stopAllSubscriptions()
    }
    
    func startGroupsSubscription(data: GroupsSubscription, update: @escaping GroupsSubscriptionCallback) async throws -> [DataviewGroup] {
        guard subscribers[data.identifier].isNil else {
            return []
        }
        
        subscribers[data.identifier] = Subscriber(data: data, callback: update)
        
        return try await groupsSubscribeService.startSubscription(
            id: data.identifier,
            relationKey: data.relationKey,
            filters: data.filters,
            source: data.source
        ).groups
    }
    
    func hasGroupsSubscriptionDataDiff(with data: GroupsSubscription) -> Bool {
        guard let subscriber = subscribers[data.identifier] else {
            return true
        }
        return data != subscriber.data
    }
    
    func stopAllSubscriptions() {
        subscribers.keys.forEach { stopGroupsSubscription(id: $0) }
    }
 
    // MARK: - Private
    
    private func stopGroupsSubscription(id: SubscriptionId) {
        guard subscribers[id].isNotNil else { return }

        _ = groupsSubscribeService.stopSubscription(id: id)
        subscribers[id] = nil
    }
    
    private func setup() {
        subscription = NotificationCenter.Publisher(
            center: .default,
            name: .middlewareEvent,
            object: nil
        )
            .compactMap { $0.object as? EventsBunch }
            .filter { $0.contextId.isEmpty }
            .receiveOnMain()
            .sink { [weak self] events in
                self?.handle(events: events)
            }
    }
    
    private func handle(events: EventsBunch) {
        // handle only Groups Subscription events
        for event in events.middlewareEvents {
            switch event.value {
            case .subscriptionGroups(let data):
                sendUpdate(
                    subId: data.subID,
                    group: data.group,
                    remove: data.remove
                )
            default:
                break
            }
        }
    }
    
    private func sendUpdate(subId: String, group: DataviewGroup, remove: Bool) {
        let subId = SubscriptionId(value: subId)
        guard let action = subscribers[subId]?.callback else {
            return
        }
        action(group, remove)
    }
}
