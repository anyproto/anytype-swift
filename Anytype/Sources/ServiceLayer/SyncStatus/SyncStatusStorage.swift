import Combine
import Services
import AnytypeCore


protocol SyncStatusStorageProtocol {
    var statusPublisher: AnyPublisher<SyncStatus, Never> { get }
    var currentStatus: SyncStatus { get }
    
    func startSubscription(spaceId: String)
    func stopSubscriptionAndClean()
}

final class SyncStatusStorage: SyncStatusStorageProtocol {
    var statusPublisher: AnyPublisher<SyncStatus, Never> { $_status.eraseToAnyPublisher() }
    var currentStatus: SyncStatus { _status }
    
    private var spaceId: String?
    
    @Published private var _status: SyncStatus = .offline // TODO: Remove
    
    private var subscription: AnyCancellable?
    
    nonisolated init() { }
    
    func startSubscription(spaceId: String) {
        self.spaceId = spaceId
        
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            Task { @MainActor [weak self] in
                self?.handle(events: events)
            }
        }
    }
    
    func stopSubscriptionAndClean() {
        subscription = nil
        spaceId = nil
        _status = .offline
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) {
        guard let spaceId else {
            anytypeAssertionFailure("Empty spaceId for in SyncStatusStorage event handle")
            return
        }
        
        for event in events.middlewareEvents {
            switch event.value {
            case .spaceSyncStatusUpdate(let update):
                guard update.id == spaceId else { return }
                
                _status = update.status as! SyncStatus
            default:
                break
            }
        }
    }
}
