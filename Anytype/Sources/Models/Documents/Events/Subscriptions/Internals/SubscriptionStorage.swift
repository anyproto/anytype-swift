import Foundation
import Services
import Combine
import AnytypeCore

protocol SubscriptionStorageProtocol: AnyObject {
    var subId: String { get }
    var total: Int { get }
    var nextCount: Int { get }
    var prevCount: Int { get }
    var items: [ObjectDetails] { get }
    var detailsStorage: ObjectDetailsStorage { get }
    
    func startOrUpdateSubscription(data: SubscriptionData, update: @MainActor @escaping () -> Void) async throws
    func stopSubscription() async throws
}

final class SubscriptionStorage: SubscriptionStorageProtocol {
    
    // MARK: - DI
    
    let subId: String
    let detailsStorage: ObjectDetailsStorage
    private let toggler: SubscriptionTogglerProtocol
    
    // MARK: - State
    
    private var subscription: AnyCancellable?
    
    private var data: SubscriptionData?
    private var update: (@MainActor () -> Void)?
    
    private(set) var orderIds: [BlockId] = []
    private(set) var items: [ObjectDetails] = []
    private(set) var total: Int = 0
    private(set) var nextCount: Int = 0
    private(set) var prevCount: Int = 0
    
    init(subId: String, detailsStorage: ObjectDetailsStorage, toggler: SubscriptionTogglerProtocol) {
        self.subId = subId
        self.detailsStorage = detailsStorage
        self.toggler = toggler
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            guard events.contextId.isEmpty else { return }
            await self?.handle(events: events)
        }
    }
    
    deinit {
        guard let data else { return }
        Task { [data, toggler] in
            try await toggler.stopSubscription(id: data.identifier)
        }
    }
    
    func startOrUpdateSubscription(data: SubscriptionData, update: @MainActor @escaping () -> Void) async throws {
        guard subId == data.identifier else {
            anytypeAssertionFailure("Ids should be equals", info: ["old id": subId, "new id": data.identifier])
            return
        }
        
        self.data = data
        self.update = update
        
        detailsStorage.removeAll()
        orderIds.removeAll()
        
        let result = try await toggler.startSubscription(data: data)
        
        result.records.forEach { detailsStorage.amend(details: $0) }
        result.dependencies.forEach { detailsStorage.amend(details: $0) }
        result.records.forEach { orderIds.append($0.id) }
        
        total = result.total
        prevCount = result.prevCount
        nextCount = result.nextCount
        
        updateItemsCache()
        await update()
    }
    
    func stopSubscription() async throws {
        guard let data else { return }
        try await toggler.stopSubscription(id: data.identifier)
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) async {
        anytypeAssert(events.localEvents.isEmpty, "Local events with emplty objectId: \(events)")
        
        var hasChanges = false
        
        for event in events.middlewareEvents {
            switch event.value {
            case .objectDetailsSet(let data):
                guard idsContainsMySub(data.subIds) else { return }
                hasChanges = true
                _ = detailsStorage.set(data: data)
            case .objectDetailsAmend(let data):
                guard idsContainsMySub(data.subIds) else { return }
                hasChanges = true
                _ = detailsStorage.amend(data: data)
            case .objectDetailsUnset(let data):
                guard idsContainsMySub(data.subIds) else { return }
                hasChanges = true
                _ = detailsStorage.unset(data: data)
            case .subscriptionPosition(let data):
                guard idsContainsMySub([data.subID]) else { return }
                hasChanges = true
                let update: SubscriptionUpdate2 = .move(from: data.id, after: data.afterID.isNotEmpty ? data.afterID : nil)
                orderIds.applySubscriptionUpdate(update)
            case .subscriptionAdd(let data):
                guard idsContainsMySub([data.subID]) else { return }
                hasChanges = true
                let update: SubscriptionUpdate2 = .add(data.id, after: data.afterID.isNotEmpty ? data.afterID : nil)
                orderIds.applySubscriptionUpdate(update)
            case .subscriptionRemove(let data):
                guard idsContainsMySub([data.subID]) else { return }
                hasChanges = true
                let update: SubscriptionUpdate2 = .remove(data.id)
                orderIds.applySubscriptionUpdate(update)
            case .objectRemove:
                break // unsupported (Not supported in middleware converter also)
            case .subscriptionCounters(let data):
                guard idsContainsMySub([data.subID]) else { return }
                hasChanges = true
                total = Int(data.total)
                nextCount = Int(data.nextCount)
                prevCount = Int(data.prevCount)
            default:
                break
            }
        }
        
        if hasChanges {
            updateItemsCache()
            await update?()
        }
    }
    
    private func idsContainsMySub(_ ids: [String]) -> Bool {
        let subIdDeps = "\(subId)/deps"
        return ids.contains(subId) || ids.contains(subIdDeps)
    }
    
    private func updateItemsCache() {
        items = orderIds.compactMap { detailsStorage.get(id: $0) }
    }
}
