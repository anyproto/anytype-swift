import Foundation
import Services
import Combine
import AnytypeCore

protocol SubscriptionStorageProtocol: AnyObject {
    var subId: String { get }
    var detailsStorage: ObjectDetailsStorage { get }
    
    func startOrUpdateSubscription(data: SubscriptionData, update: @MainActor @escaping (_ state: SubscriptionStorageState) -> Void) async throws
    func stopSubscription() async throws
}

actor SubscriptionStorage: SubscriptionStorageProtocol {
    
    // MARK: - DI
    
    nonisolated let subId: String
    nonisolated let detailsStorage: ObjectDetailsStorage
    private let toggler: SubscriptionTogglerProtocol
    
    // MARK: - State
    
    private var subscription: AnyCancellable?
    
    private var data: SubscriptionData?
    private var update: (@MainActor (_ data: SubscriptionStorageState) -> Void)?
    
    private var orderIds: [String] = []
    private var state = SubscriptionStorageState(total: 0, nextCount: 0, prevCount: 0, items: [])
    
    init(subId: String, detailsStorage: ObjectDetailsStorage, toggler: SubscriptionTogglerProtocol) {
        self.subId = subId
        self.detailsStorage = detailsStorage
        self.toggler = toggler
        Task { await setupHandler() }
    }
    
    deinit {
        guard let data else { return }
        Task { [data, toggler] in
            try await toggler.stopSubscription(id: data.identifier)
        }
    }
    
    func startOrUpdateSubscription(data: SubscriptionData, update: @MainActor @escaping (_ state: SubscriptionStorageState) -> Void) async throws {
        guard subId == data.identifier else {
            anytypeAssertionFailure("Ids should be equals", info: ["old id": subId, "new id": data.identifier])
            return
        }
        
        let result = try await toggler.startSubscription(data: data)
        
        self.data = data
        self.update = update
        
        detailsStorage.removeAll()
        orderIds.removeAll()
        
        result.records.forEach { detailsStorage.amend(details: $0) }
        result.dependencies.forEach { detailsStorage.amend(details: $0) }
        result.records.forEach { orderIds.append($0.id) }
        
        state.total = result.total
        state.prevCount = result.prevCount
        state.nextCount = result.nextCount
        
        updateItemsCache()
        await update(state)
    }
    
    func stopSubscription() async throws {
        guard let data else { return }
        try await toggler.stopSubscription(id: data.identifier)
    }
    
    // MARK: - Private
    
    private func setupHandler() {
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            guard events.contextId.isEmpty else { return }
            await self?.handle(events: events)
        }
    }
    
    private func handle(events: EventsBunch) async {
        anytypeAssert(events.localEvents.isEmpty, "Local events with emplty objectId: \(events)")
        
        let oldState = state
        
        for event in events.middlewareEvents {
            switch event.value {
            case .objectDetailsSet(let data):
                guard idsContainsMySub(data.subIds, incudeDeps: true) else { break }
                _ = detailsStorage.set(data: data)
            case .objectDetailsAmend(let data):
                guard idsContainsMySub(data.subIds, incudeDeps: true) else { break }
                _ = detailsStorage.amend(data: data)
            case .objectDetailsUnset(let data):
                guard idsContainsMySub(data.subIds, incudeDeps: true) else { break }
                _ = detailsStorage.unset(data: data)
            case .subscriptionPosition(let data):
                guard idsContainsMySub([data.subID]) else { break }
                let update: SubscriptionUpdate = .move(from: data.id, after: data.afterID.isNotEmpty ? data.afterID : nil)
                orderIds.applySubscriptionUpdate(update)
            case .subscriptionAdd(let data):
                guard idsContainsMySub([data.subID]) else { break }
                let update: SubscriptionUpdate = .add(data.id, after: data.afterID.isNotEmpty ? data.afterID : nil)
                orderIds.applySubscriptionUpdate(update)
            case .subscriptionRemove(let data):
                guard idsContainsMySub([data.subID]) else { break }
                let update: SubscriptionUpdate = .remove(data.id)
                orderIds.applySubscriptionUpdate(update)
            case .objectRemove:
                break // unsupported (Not supported in middleware converter also)
            case .subscriptionCounters(let data):
                guard idsContainsMySub([data.subID]) else { break }
                state.total = Int(data.total)
                state.nextCount = Int(data.nextCount)
                state.prevCount = Int(data.prevCount)
            default:
                break
            }
        }
        
        state.items = orderIds.compactMap { detailsStorage.get(id: $0) }
        
        if oldState != state {
            updateItemsCache()
            await update?(state)
        }
    }
    
    private func idsContainsMySub(_ ids: [String], incudeDeps: Bool = false) -> Bool {
        if incudeDeps {
            let subIdDeps = "\(subId)/dep"
            return ids.contains(subId) || ids.contains(subIdDeps)
        } else {
            return ids.contains(subId)
        }
    }
    
    private func updateItemsCache() {
        state.items = orderIds.compactMap { detailsStorage.get(id: $0) }
    }
}
