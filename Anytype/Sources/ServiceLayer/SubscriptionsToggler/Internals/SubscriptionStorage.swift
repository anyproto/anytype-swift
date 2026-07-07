import Foundation
import Services
@preconcurrency import Combine
import AnytypeCore

protocol SubscriptionStorageProtocol: AnyObject, Sendable {
    var subId: String { get }
    var detailsStorage: ObjectDetailsStorage { get }
    
    var statePublisher: AnyPublisher<SubscriptionStorageState, Never> { get }
    func startOrUpdateSubscription(data: SubscriptionData, update: @escaping @Sendable (_ state: SubscriptionStorageState) async -> Void) async throws
    func startOrUpdateSubscription(data: SubscriptionData) async throws
    func stopSubscription() async throws
}

actor SubscriptionStorage: SubscriptionStorageProtocol {
    
    // MARK: - DI
    
    nonisolated let subId: String
    nonisolated let detailsStorage: ObjectDetailsStorage
    private let toggler: any SubscriptionTogglerProtocol
    
    // MARK: - State
    
    private var subscription: AnyCancellable?
    private var handlerRegistration: Task<Void, Never>?
    private var pendingEvents: [EventsBunch]?

    private var data: SubscriptionData?
    private var update: (@Sendable (_ data: SubscriptionStorageState) async -> Void)?
    
    private var orderIds: [String] = []
    private var state = SubscriptionStorageState(total: 0, nextCount: 0, prevCount: 0, items: [])
    private let stateSubject = CurrentValueSubject<SubscriptionStorageState?, Never>(nil)
    nonisolated let statePublisher: AnyPublisher<SubscriptionStorageState, Never>
    
    init(subId: String, detailsStorage: ObjectDetailsStorage, toggler: some SubscriptionTogglerProtocol) {
        self.subId = subId
        self.detailsStorage = detailsStorage
        self.toggler = toggler
        self.statePublisher = stateSubject.compactMap { $0 }.eraseToAnyPublisher()
        handlerRegistration = Task { await setupHandler() }
    }
    
    deinit {
        guard let data else { return }
        Task { [data, toggler] in
            try await toggler.stopSubscription(id: data.identifier)
        }
    }
    
    func startOrUpdateSubscription(data: SubscriptionData) async throws {
        try await startOrUpdateSubscription(data: data, update: { _ in })
    }
    
    func startOrUpdateSubscription(data: SubscriptionData, update: @escaping @Sendable (_ state: SubscriptionStorageState) async -> Void) async throws {
        guard subId == data.identifier else {
            anytypeAssertionFailure("Ids should be equals", info: ["old id": subId, "new id": data.identifier])
            return
        }
        
        guard self.data != data else {
            // Always replace the callback so a later caller's closure wins
            // (e.g. loader pre-warms with no-op, VM mounts with real handler).
            self.update = update
            await update(state)
            stateSubject.send(state)
            return
        }

        // Ensure the event handler is registered before issuing the subscribe RPC,
        // so an event that races the response is not missed.
        await handlerRegistration?.value

        // Capture events arriving during the in-flight subscribe instead of mutating
        // live state (which the removeAll() + records seed below would wipe).
        pendingEvents = []
        let result: SubscriptionTogglerResult
        do {
            result = try await toggler.startSubscription(data: data)
        } catch {
            pendingEvents = nil
            throw error
        }

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

        // Replay events that arrived during the in-flight subscribe so an event-delivered
        // record missing from the response snapshot is reconciled in.
        let buffered = pendingEvents
        pendingEvents = nil
        buffered?.forEach { applyEvents($0) }

        updateItemsCache()
        await update(state)
        stateSubject.send(state)
    }
    
    func stopSubscription() async throws {
        guard let data else { return }
        try await toggler.stopSubscription(id: data.identifier)
        self.data = nil
    }
    
    // MARK: - Private
    
    private func setupHandler() async {
        subscription = await EventBunchSubscribtion.default.addHandlerAwaiting { [weak self] events in
            guard events.contextId.isEmpty else { return }
            await self?.handle(events: events)
        }
    }
    
    private func handle(events: EventsBunch) async {
        anytypeAssert(events.localEvents.isEmpty, "Local events with emplty objectId: \(events)")

        // A subscribe RPC is in flight: buffer and reconcile after the response snapshot.
        if pendingEvents != nil {
            pendingEvents?.append(events)
            return
        }

        let oldState = state
        applyEvents(events)

        if oldState != state {
            updateItemsCache()
            await update?(state)
            stateSubject.send(state)
        }
    }

    private func applyEvents(_ events: EventsBunch) {
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
                guard !orderIds.contains(data.id) else { break }
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
