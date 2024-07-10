import Combine
import Services
import AnytypeCore
import ProtobufMessages


protocol SyncStatusStorageProtocol {
    func statusPublisher(spaceId: String) -> AnyPublisher<SyncStatusInfo?, Never>
    
    func startSubscription()
    func stopSubscriptionAndClean()
}

final class SyncStatusStorage: SyncStatusStorageProtocol {
    @Published private var _update: Anytype_Event.Space.SyncStatus.Update?
    private var updatePublisher: AnyPublisher<Anytype_Event.Space.SyncStatus.Update?, Never> { $_update.eraseToAnyPublisher() }
    private var subscription: AnyCancellable?
    
    private var defaultValues = [String: SyncStatusInfo]()
    
    nonisolated init() { }
    
    func statusPublisher(spaceId: String) -> AnyPublisher<SyncStatusInfo?, Never> {
        updatePublisher
            .filter { $0?.id == spaceId}
            .merge(with: Just(defaultValues[spaceId]))
            .eraseToAnyPublisher()
    }
    
    func startSubscription() {
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            Task { @MainActor [weak self] in
                self?.handle(events: events)
            }
        }
    }
    
    func stopSubscriptionAndClean() {
        subscription = nil
        _update = nil
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case .spaceSyncStatusUpdate(let update):
                defaultValues[update.id] = update
                _update = update
            default:
                break
            }
        }
    }
}
