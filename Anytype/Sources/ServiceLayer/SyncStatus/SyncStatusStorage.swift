import Combine
import Services
import AnytypeCore
import ProtobufMessages


@MainActor
protocol SyncStatusStorageProtocol {
    func statusPublisher(spaceId: String) -> AnyPublisher<SyncStatusInfo, Never>
    
    func startSubscription()
    func stopSubscriptionAndClean()
}

@MainActor
final class SyncStatusStorage: SyncStatusStorageProtocol {
    @Published private var storage = [String: SyncStatusInfo]()
    private var subscription: AnyCancellable?
    
    nonisolated init() { }
    
    func statusPublisher(spaceId: String) -> AnyPublisher<SyncStatusInfo, Never> {
        $storage
            .compactMap { $0[spaceId] }
            .eraseToAnyPublisher()
    }
    
    func startSubscription() {
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            await self?.handle(events: events)
        }
    }
    
    func stopSubscriptionAndClean() {
        anytypeAssert(subscription.isNotNil, "Nil subscription in SyncStatusStorage")
        subscription = nil
        storage = [:]
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case .spaceSyncStatusUpdate(let update):
                storage[update.id] = update
            default:
                break
            }
        }
    }
}
