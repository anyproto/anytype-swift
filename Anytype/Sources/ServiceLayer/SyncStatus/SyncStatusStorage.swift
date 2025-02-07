import Combine
import Services
import AnytypeCore
import ProtobufMessages

protocol SyncStatusStorageProtocol: Sendable {
    func statusPublisher(spaceId: String) -> AnyPublisher<SyncStatusInfo, Never>
    
    func startSubscription() async
    func stopSubscriptionAndClean() async
}

actor SyncStatusStorage: SyncStatusStorageProtocol, Sendable {
    
    private let storage = AtomicPublishedStorage([String: SyncStatusInfo]())
    private var subscription: AnyCancellable?
    
    init() { }
    
    nonisolated func statusPublisher(spaceId: String) -> AnyPublisher<SyncStatusInfo, Never> {
        storage.publisher
            .compactMap { $0[spaceId] }
            .eraseToAnyPublisher()
    }
    
    func startSubscription() async {
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            await self?.handle(events: events)
        }
    }
    
    func stopSubscriptionAndClean() async {
        anytypeAssert(subscription.isNotNil, "Nil subscription in SyncStatusStorage")
        subscription = nil
        storage.value = [:]
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case .spaceSyncStatusUpdate(let update):
                storage.value[update.id] = update
            default:
                break
            }
        }
    }
}
