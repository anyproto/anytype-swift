import Combine
import Services
import AnytypeCore
import ProtobufMessages


protocol P2PStatusStorageProtocol {
    func statusPublisher(spaceId: String) async -> AnyPublisher<P2PStatusInfo?, Never>
    
    func startSubscription() async
    func stopSubscriptionAndClean() async
}

actor P2PStatusStorage: P2PStatusStorageProtocol {
    @Published private var _update: P2PStatusInfo?
    private var updatePublisher: AnyPublisher<P2PStatusInfo?, Never> { $_update.eraseToAnyPublisher() }
    private var subscription: AnyCancellable?
    
    private var defaultValues = [String: P2PStatusInfo]()
    
    init() { }
    
    func statusPublisher(spaceId: String) -> AnyPublisher<P2PStatusInfo?, Never> {
        updatePublisher
            .filter { $0?.spaceID == spaceId}
            .merge(with: Just(defaultValues[spaceId]))
            .eraseToAnyPublisher()
    }
    
    func startSubscription() {
        anytypeAssert(subscription.isNil, "Non nil subscription in P2PStatusStorage")
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            await self?.handle(events: events)
        }
    }
    
    func stopSubscriptionAndClean() {
        anytypeAssert(subscription.isNotNil, "Nil subscription in P2PStatusStorage")
        subscription = nil
        _update = nil
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case .p2PStatusUpdate(let update):
                defaultValues[update.spaceID] = update
                _update = update
            default:
                break
            }
        }
    }
}
