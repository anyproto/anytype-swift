import Foundation
import ProtobufMessages
import Combine
import Services


protocol FileLimitsStorageProtocol: AnyObject {
    var nodeUsage: AnyPublisher<NodeUsageInfo, Never> { get }
}


final class FileLimitsStorage: FileLimitsStorageProtocol, @unchecked Sendable {
    
    // MARK: - DI
    
    @Injected(\.fileActionsService)
    private var fileService: any FileActionsServiceProtocol
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    @Published private var data: NodeUsageInfo?
    var nodeUsage: AnyPublisher<NodeUsageInfo, Never> {
        $data.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    nonisolated init() {
        Task {
            try await setupInitialState()
        }
    }
    
    // MARK: - Private
        
    private func setupInitialState() async throws {
        stopSubscription()
        let nodeUsage = try await fileService.nodeUsage()
        data = nodeUsage
        setupSubscription()
    }
    
    private func setupSubscription() {
        EventBunchSubscribtion.default.addHandler { [weak self] events in
            Task { @MainActor [weak self] in
                self?.handle(events: events)
            }
        }.store(in: &subscriptions)
    }
    
    private func stopSubscription() {
        subscriptions.removeAll()
    }
    
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case let .fileLocalUsage(eventData):
                data?.node.localBytesUsage = Int64(clamping: eventData.localBytesUsage)
            case let .fileSpaceUsage(eventData):
                guard let spaceIndex = data?.spaces.firstIndex(where: { $0.spaceID == eventData.spaceID }) else { return }
                data?.spaces[spaceIndex].bytesUsage = Int64(clamping: eventData.bytesUsage)
            case let .fileLimitUpdated(eventData):
                data?.node.bytesLimit = Int64(clamping: eventData.bytesLimit)
            default:
                break
            }
        }
    }
}
