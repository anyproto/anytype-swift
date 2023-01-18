import BlocksModels
import Combine
import AnytypeCore
import NotificationCenter

final class SubscriptionsService: SubscriptionsServiceProtocol {
    
    private struct Subscriber {
        let data: SubscriptionData
        let callback: SubscriptionCallback
    }
    
    private var subscription: AnyCancellable?
    private let toggler: SubscriptionTogglerProtocol
    private let storage: ObjectDetailsStorage
    
    private var subscribers = [SubscriptionId: Subscriber]()
    
    init(toggler: SubscriptionTogglerProtocol, storage: ObjectDetailsStorage) {
        self.toggler = toggler
        self.storage = storage
        
        setup()
    }
    
    deinit {
        stopAllSubscriptions()
    }
    
    func stopAllSubscriptions() {
        subscribers.keys.forEach { stopSubscription(id: $0) }
    }
    
    func stopSubscriptions(ids: [SubscriptionId]) {
        ids.forEach { stopSubscription(id: $0) }
    }
    
    func stopSubscription(id: SubscriptionId) {
        guard subscribers[id].isNotNil else { return }

        _ = toggler.stopSubscription(id: id)
        subscribers[id] = nil
    }
    
    func startSubscriptions(data: [SubscriptionData], update: @escaping SubscriptionCallback) {
        data.forEach { startSubscription(data: $0, update: update) }
    }
    
    func startSubscription(data: SubscriptionData, update: @escaping SubscriptionCallback) {
        guard subscribers[data.identifier].isNil else {
            anytypeAssertionFailure("Subscription: \(data) started on second time", domain: .subscriptionStorage)
            return
        }
        
        subscribers[data.identifier] = Subscriber(data: data, callback: update)
        
        guard let result = toggler.startSubscription(data: data) else { return }
        
        result.records.forEach { storage.amend(details: $0) }
        result.dependencies.forEach { storage.amend(details: $0) }
        
        update(data.identifier, .initialData(result.records))
        update(data.identifier, .pageCount(numberOfPagesFromTotalCount(result.count, numberOfRowsPerPage: data.rowsPerPage)))
    }
    
    func hasSubscriptionDataDiff(with data: SubscriptionData) -> Bool {
        guard let subscriber = subscribers[data.identifier] else {
            return true
        }
        return data != subscriber.data
    }
 
    // MARK: - Private
    private let dependencySubscriptionSuffix = "/dep"
    
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
        anytypeAssert(events.localEvents.isEmpty, "Local events with emplty objectId: \(events)", domain: .subscriptionStorage)
        
        for event in events.middlewareEvents {
            switch event.value {
            case .objectDetailsSet(let data):
                guard let details = storage.set(data: data) else { return }
                update(details: details, ids: data.subIds)
            case .objectDetailsAmend(let data):
                guard let details = storage.amend(data: data) else { return }
                update(details: details, ids: data.subIds)
            case .objectDetailsUnset(let data):
                guard let details = storage.unset(data: data) else { return }
                update(details: details, ids: data.subIds)
            case .subscriptionPosition(let position):
                let update: SubscriptionUpdate = .move(from: position.id, after: position.afterID.isNotEmpty ? position.afterID : nil)
                sendUpdate(update, subId: position.subID)
            case .subscriptionAdd(let data):
                guard
                    let details = storage.get(id: data.id)
                else {
                    anytypeAssertionFailure("No details found for id \(data.id)", domain: .subscriptionStorage)
                    return
                }
                
                let update: SubscriptionUpdate = .add(details, after: data.afterID.isNotEmpty ? data.afterID : nil)
                sendUpdate(update, subId: data.subID)
            case .subscriptionRemove(let remove):
                sendUpdate(.remove(remove.id), subId: remove.subID)
            case .objectRemove:
                break // unsupported (Not supported in middleware converter also)
            case .subscriptionCounters(let data):
                sendUpdate(
                    .pageCount(numberOfPagesFromTotalCount(
                        Int(data.total),
                        numberOfRowsPerPage: Int(data.total - data.nextCount)
                    )),
                    subId: data.subID
                )
            case .accountConfigUpdate, .accountUpdate, .accountDetails, .accountShow, .subscriptionGroups:
                break
            default:
                anytypeAssertionFailure("Unsupported event \(event)", domain: .subscriptionStorage)
            }
        }
    }
    
    private func sendUpdate(_ update: SubscriptionUpdate, subId: String) {
        let subId = SubscriptionId(value: subId)
        guard let action = subscribers[subId]?.callback else {
            return
        }
        action(subId, update)
    }
    
    private func update(details: ObjectDetails, ids: [String]) {
        for id in ids {
            let id = SubscriptionId(value: id)
            guard let action = subscribers[id]?.callback else {
                continue
            }
            action(id, .update(details))
        }
    }
    
    private func numberOfPagesFromTotalCount(_ count: Int, numberOfRowsPerPage: Int) -> Int {
        guard numberOfRowsPerPage > 0 else { return 0 }
        // Returns 1 if count < numberOfRowsPerPage
        // And returns 1 if count = numberOfRowsPerPage
        let closestNumberToRowsPerPage = numberOfRowsPerPage - 1
        return (count + closestNumberToRowsPerPage) / numberOfRowsPerPage
    }
}
