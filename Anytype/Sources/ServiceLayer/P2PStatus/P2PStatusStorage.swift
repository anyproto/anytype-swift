import Combine
import Services
import AnytypeCore
import ProtobufMessages


@MainActor
protocol P2PStatusStorageProtocol {
    func statusPublisher(spaceId: String) -> AnyPublisher<P2PStatusInfo, Never>
    
    func startSubscription()
    func stopSubscriptionAndClean()
}

@MainActor
final class P2PStatusStorage: P2PStatusStorageProtocol {
    @Published private var storage = [String: P2PStatusInfo]()
    private var subscription: AnyCancellable?
    
    
    nonisolated init() { }
    
    func statusPublisher(spaceId: String) -> AnyPublisher<P2PStatusInfo, Never> {
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
        anytypeAssert(subscription.isNotNil, "Nil subscription in P2PStatusStorage")
        subscription = nil
        storage = [:]
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case .p2PStatusUpdate(let update):
                storage[update.spaceID] = update
            default:
                break
            }
        }
    }
}
