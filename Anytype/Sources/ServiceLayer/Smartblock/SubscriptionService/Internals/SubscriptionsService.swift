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
        turnedOnSubs.keys.forEach { subId in
            _ = toggler.toggleSubscription(id: subId, false)
            turnedOnSubs[subId] = nil
        }
    }
    
    func stopSubscriptions(ids: [SubscriptionId]) {
        ids.forEach { stopSubscription(id: $0) }
    }
    
    func stopSubscription(id: SubscriptionId) {
        _ = toggler.toggleSubscription(id: id, false)
        turnedOnSubs[id] = nil
    }
    
    func startSubscriptions(ids: [SubscriptionId], update: @escaping SubscriptionCallback) {
        ids.forEach { startSubscription(id: $0, update: update) }
    }
    
    func startSubscription(id: SubscriptionId, update: @escaping SubscriptionCallback) {
        guard turnedOnSubs[id].isNil else {
            anytypeAssertionFailure("Subscription: \(id) started on second time", domain: .subscriptionStorage)
            return
        }
        
        turnedOnSubs[id] = update
        
        let details = toggler.toggleSubscription(id: id, true) ?? []
        details.forEach { storage.add(details: $0) }
        
        update(id, .initialData(details))
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
            .filter { [weak self] event in
                guard let self = self else { return false }
                guard event.objectId.isNotEmpty else { return true } // Empty object id in generic subscription
                
                guard let subscription = SubscriptionId(identifier: event.objectId) else {
                    return false
                }
                
                return self.turnedOnSubs.keys.contains(subscription)
            }
            .receiveOnMain()
            .sink { [weak self] events in
                self?.handle(events: events)
            }
    }
    
    private func handle(events: EventsBunch) {
        anytypeAssert(events.localEvents.isEmpty, "Local events with emplty objectId: \(events)", domain: .subscriptionStorage)
        
        for event in events.middlewareEvents {
            switch event.value {
            case .objectDetailsAmend(let data):
                let currentDetails = storage.get(id: data.id) ?? ObjectDetails.empty(id: data.id)
                
                let updatedDetails = currentDetails.updated(by: data.details.asDetailsDictionary)
                storage.add(details: updatedDetails)
                
                update(details: updatedDetails, rawSubIds: data.subIds)
            case .subscriptionPosition(let position):
                guard let subId = SubscriptionId(identifier: events.objectId) else {
                    anytypeAssertionFailure("Unsupported object id \(events.objectId) in subscriptionPosition", domain: .subscriptionStorage)
                    break
                }
                
                guard let action = turnedOnSubs[subId] else { return }
                action(subId, .move(from: position.id, after: position.afterID.isNotEmpty ? position.afterID : nil))
            case .subscriptionAdd(let data):
                guard let subId = SubscriptionId(identifier: events.objectId) else {
                    anytypeAssertionFailure("Unsupported object id \(events.objectId) in subscriptionRemove", domain: .subscriptionStorage)
                    break
                }
                
                guard let details = storage.get(id: data.id) else {
                    anytypeAssertionFailure("No details found for id \(data.id)", domain: .subscriptionStorage)
                    return
                }
                
                guard let action = turnedOnSubs[subId] else { return }
                action(subId, .add(details, after: data.afterID.isNotEmpty ? data.afterID : nil))
            case .subscriptionRemove(let remove):
                guard let subId = SubscriptionId(identifier: events.objectId) else {
                    anytypeAssertionFailure("Unsupported object id \(events.objectId) in subscriptionRemove", domain: .subscriptionStorage)
                    break
                }
                
                guard let action = turnedOnSubs[subId] else { return }
                action(subId, .remove(remove.id))
            case .objectRemove:
                break // unsupported (Not supported in middleware converter also)
            case .subscriptionCounters:
                break // unsupported for now. Used for pagination
            case .accountConfigUpdate:
                break
            default:
                anytypeAssertionFailure("Unupported event \(event)", domain: .subscriptionStorage)
            }
        }
    }
    
    private func update(details: ObjectDetails, rawSubIds: [String]) {
        let ids: [SubscriptionId] = rawSubIds.compactMap { rawId in
            guard let id = SubscriptionId(identifier: rawId) else {
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
}
