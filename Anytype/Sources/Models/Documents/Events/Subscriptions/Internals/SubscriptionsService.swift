import BlocksModels
import Combine
import AnytypeCore

final class SubscriptionsService: SubscriptionsServiceProtocol {
    private var subscription: AnyCancellable?
    private let toggler: SubscriptionTogglerProtocol
    private let storage: ObjectDetailsStorage
    
    private var turnedOnSubs = [SubscriptionId: SubscriptionCallback]()
    
    init(toggler: SubscriptionTogglerProtocol, storage: ObjectDetailsStorage) {
        self.toggler = toggler
        self.storage = storage
        
        setup()
    }
    
    deinit {
        stopAllSubscriptions()
    }
    
    func stopAllSubscriptions() {
        turnedOnSubs.keys.forEach { stopSubscription(id: $0) }
    }
    
    func stopSubscriptions(ids: [SubscriptionId]) {
        ids.forEach { stopSubscription(id: $0) }
    }
    
    func stopSubscription(id: SubscriptionId) {
        _ = toggler.stopSubscription(id: id)
        turnedOnSubs[id] = nil
    }
    
    func startSubscriptions(data: [SubscriptionData], update: @escaping SubscriptionCallback) {
        data.forEach { startSubscription(data: $0, update: update) }
    }
    
    func startSubscription(data: SubscriptionData, update: @escaping SubscriptionCallback) {
        guard turnedOnSubs[data.identifier].isNil else {
            anytypeAssertionFailure("Subscription: \(data) started on second time", domain: .subscriptionStorage)
            return
        }
        
        turnedOnSubs[data.identifier] = update
        
        guard let (details, count) = toggler.startSubscription(data: data) else { return }
        
        details.forEach { storage.amend(details: $0) }
        update(data.identifier, .initialData(details))
        update(data.identifier, .pageCount(numberOfPagesFromTotalCount(count)))
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
                update(details: details, rawSubIds: data.subIds)
            case .objectDetailsAmend(let data):
                let details = storage.amend(data: data)
                update(details: details, rawSubIds: data.subIds)
            case .objectDetailsUnset(let data):
                guard let details = storage.unset(data: data) else { return }
                update(details: details, rawSubIds: data.subIds)
            case .subscriptionPosition(let position):
                let update: SubscriptionUpdate = .move(from: position.id, after: position.afterID.isNotEmpty ? position.afterID : nil)
                sendUpdate(update, subId: position.subID)
            case .subscriptionAdd(let data):
                guard let details = storage.get(id: data.id) else {
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
                sendUpdate(.pageCount(numberOfPagesFromTotalCount(data.total)), subId: data.subID)
            case .accountConfigUpdate:
                break
            case .accountDetails:
                break
            default:
                anytypeAssertionFailure("Unupported event \(event)", domain: .subscriptionStorage)
            }
        }
    }
    
    private func sendUpdate(_ update: SubscriptionUpdate, subId: String) {
        guard let subId = SubscriptionId(rawValue: subId) else {
            if !subId.hasSuffix(dependencySubscriptionSuffix) {
                anytypeAssertionFailure("Unrecognized subscription: \(subId)", domain: .subscriptionStorage)
            }
            return
        }
        guard let action = turnedOnSubs[subId] else { return }
        action(subId, update)
    }
    
    private func update(details: ObjectDetails, rawSubIds: [String]) {
        let ids: [SubscriptionId] = rawSubIds.compactMap { rawId in
            guard let id = SubscriptionId(rawValue: rawId) else {
                if !rawId.hasSuffix(dependencySubscriptionSuffix) {
                    anytypeAssertionFailure("Unrecognized subscription: \(rawId)", domain: .subscriptionStorage)
                }
                return nil
            }
            
            return id
        }
        
        for id in ids {
            guard let action = turnedOnSubs[id] else { continue }
            action(id, .update(details))
        }
    }
    
    private func numberOfPagesFromTotalCount(_ count: Int64) -> Int64 {
        let numberOfRowsPerPageInSubscriptions = UserDefaultsConfig.rowsPerPageInSet
        // Returns 1 if count < numberOfRowsPerPageInSubscriptions
        // And returns 1 if count = numberOfRowsPerPageInSubscriptions
        let closestNumberToRowsPerPage = numberOfRowsPerPageInSubscriptions - 1
        return (count + closestNumberToRowsPerPage) / numberOfRowsPerPageInSubscriptions
    }
}
