import Combine
import Services
import AnytypeCore
import ProtobufMessages

protocol P2PStatusStorageProtocol: Sendable {
    func statusPublisher(spaceId: String) -> AnyPublisher<P2PStatusInfo, Never>
    
    func startSubscription() async
    func stopSubscriptionAndClean() async
}

actor P2PStatusStorage: P2PStatusStorageProtocol, Sendable {
    
    private let storage = AtomicPublishedStorage([String: P2PStatusInfo]())
    private var subscription: AnyCancellable?
    
    init() { }
    
    nonisolated func statusPublisher(spaceId: String) -> AnyPublisher<P2PStatusInfo, Never> {
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
        anytypeAssert(subscription.isNotNil, "Nil subscription in P2PStatusStorage")
        subscription = nil
        storage.value = [:]
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case .p2PStatusUpdate(let update):
                storage.value[update.spaceID] = update
            default:
                break
            }
        }
    }
}
