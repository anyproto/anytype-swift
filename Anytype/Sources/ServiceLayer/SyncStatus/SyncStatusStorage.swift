import Combine
import Services
import AnytypeCore
import ProtobufMessages

protocol SyncStatusStorageProtocol: Sendable {
    func statusPublisher(spaceId: String) -> AnyPublisher<SpaceSyncStatusInfo, Never>
    func allSpacesStatusPublisher() -> AnyPublisher<[SpaceSyncStatusInfo], Never>

    func startSubscription() async
    func stopSubscriptionAndClean() async
}

actor SyncStatusStorage: SyncStatusStorageProtocol, Sendable {

    // WORKAROUND: Force linker to retain Anytype_Event.Space.SyncStatus metadata.
    // This empty wrapper struct gets stripped in Release builds because it's never
    // directly referenced. Its nested Update type (SpaceSyncStatusInfo) needs the
    // parent metadata to be present, causing null pointer crash if stripped.
    private static let _forceParentTypeRetention: Anytype_Event.Space.SyncStatus.Type =
        Anytype_Event.Space.SyncStatus.self

    private let storage = AtomicPublishedStorage([String: SpaceSyncStatusInfo]())
    private var subscription: AnyCancellable?
    
    init() { }
    
    nonisolated func statusPublisher(spaceId: String) -> AnyPublisher<SpaceSyncStatusInfo, Never> {
        storage.publisher
            .compactMap { $0[spaceId] }
            .eraseToAnyPublisher()
    }

    nonisolated func allSpacesStatusPublisher() -> AnyPublisher<[SpaceSyncStatusInfo], Never> {
        storage.publisher
            .map { Array($0.values) }
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
