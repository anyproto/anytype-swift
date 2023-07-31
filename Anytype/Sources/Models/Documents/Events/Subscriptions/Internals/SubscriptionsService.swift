import Services
import Combine
import AnytypeCore
import NotificationCenter
import AsyncQueue

final class SubscriptionsService: SubscriptionsServiceProtocol {
    
    private struct Subscriber {
        let data: SubscriptionData
        let callback: SubscriptionCallback
    }
    
    // MARK: - Private properties
    
    private var subscription: AnyCancellable?
    private let toggler: SubscriptionTogglerProtocol
    
    private var subscribers = [String: Subscriber]()
    private let taskQueue = FIFOQueue()
    
    // MARK: - Public properties
    
    let storage: ObjectDetailsStorage
    
    init(toggler: SubscriptionTogglerProtocol, storage: ObjectDetailsStorage) {
        self.toggler = toggler
        self.storage = storage
        
        setup()
    }
    
    deinit {
        // Without queue. Queue will be cancelled
        let ids = Array(subscribers.keys)
        guard ids.isNotEmpty else { return }
        Task { [ids, toggler] in
            try? await toggler.stopSubscriptions(ids: ids)
        }
    }
    
    func updateSubscription(data: SubscriptionData, required: Bool, update: @escaping SubscriptionCallback) {
        taskQueue.enqueue { [weak self] in
            guard let self = self else { return }
            
            guard required || hasSubscriptionDataDiff(with: data) else { return }
            
            await unsafeStopSubscriptions(ids: [data.identifier])
            await unsafeStartSubscription(data: data, update: update)
        }
    }
    
    func stopAllSubscriptions() {
        taskQueue.enqueue { [weak self] in
            guard let self = self else { return }
            
            let ids = Array(subscribers.keys)
            stopSubscriptions(ids: ids)
        }
    }
    
    func stopSubscriptions(ids: [String]) {
        taskQueue.enqueue { [weak self] in
            guard let self = self else { return }
            
            let idsToDelete = subscribers.keys.filter { ids.contains($0) }
            guard idsToDelete.isNotEmpty else { return }
            
            try? await toggler.stopSubscriptions(ids: idsToDelete)
            for id in idsToDelete {
                subscribers[id] = nil
            }
        }
    }
    
    func stopSubscription(id: String) {
        taskQueue.enqueue { [weak self] in
            await self?.unsafeStopSubscriptions(ids: [id])
        }
    }
    
    func startSubscriptions(data: [SubscriptionData], update: @escaping SubscriptionCallback) {
        taskQueue.enqueue { [weak self] in
            for subData in data {
                await self?.unsafeStartSubscription(data: subData, update: update)
            }
        }
    }
    
    func startSubscription(data: SubscriptionData, update: @escaping SubscriptionCallback) {
        taskQueue.enqueue { [weak self] in
            await self?.unsafeStartSubscription(data: data, update: update)
        }
    }
    
    func startSubscriptionAsync(data: SubscriptionData, update: @escaping SubscriptionCallback) async {
        await taskQueue.enqueueAndWait { [weak self] in
            await self?.unsafeStartSubscription(data: data, update: update)
        }
    }
 
    // MARK: - Private
    
    private func hasSubscriptionDataDiff(with data: SubscriptionData) -> Bool {
        guard let subscriber = subscribers[data.identifier] else {
            return true
        }
        return data != subscriber.data
    }
 
    func unsafeStartSubscription(data: SubscriptionData, update: @escaping SubscriptionCallback) async {
        guard let result = try? await toggler.startSubscription(data: data) else { return }
        
        subscribers[data.identifier] = Subscriber(data: data, callback: update)
        
        result.records.forEach { storage.amend(details: $0) }
        result.dependencies.forEach { storage.amend(details: $0) }
        
        await MainActor.run {
            update(data.identifier, .initialData(result.records))
            update(data.identifier, .pageCount(numberOfPagesFromTotalCount(result.count, numberOfRowsPerPage: data.rowsPerPage)))
        }
    }
    
    func unsafeStopSubscriptions(ids: [String]) async {
        let idsToDelete = subscribers.keys.filter { ids.contains($0) }
        guard idsToDelete.isNotEmpty else { return }
        
        try? await toggler.stopSubscriptions(ids: idsToDelete)
        for id in idsToDelete {
            subscribers[id] = nil
        }
    }
    
    private let dependencySubscriptionSuffix = "/dep"
    
    private func setup() {
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            guard events.contextId.isEmpty else { return }
            await self?.handle(events: events)
        }
    }
    
    @MainActor
    private func handle(events: EventsBunch) {
        anytypeAssert(events.localEvents.isEmpty, "Local events with emplty objectId: \(events)")
        
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
                    anytypeAssertionFailure("No details found", info: ["id": data.id])
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
            default:
                break
            }
        }
    }
    
    private func sendUpdate(_ update: SubscriptionUpdate, subId: String) {
        guard let action = subscribers[subId]?.callback else {
            return
        }
        action(subId, update)
    }
    
    private func update(details: ObjectDetails, ids: [String]) {
        for id in ids {
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
