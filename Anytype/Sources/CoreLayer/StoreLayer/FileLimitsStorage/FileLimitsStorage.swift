import Foundation
import ProtobufMessages
import Combine
import Services

@MainActor
protocol FileLimitsStorageProtocol: AnyObject {
    var nodeUsage: AnyPublisher<NodeUsageInfo, Never> { get }
}

@MainActor
final class FileLimitsStorage: FileLimitsStorageProtocol {
    
    // MAKR: - DI
    
    private let fileService: FileActionsServiceProtocol
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var data: CurrentValueSubject<NodeUsageInfo?, Never>
    let nodeUsage: AnyPublisher<NodeUsageInfo, Never>
    
    nonisolated init(fileService: FileActionsServiceProtocol) {
        self.fileService = fileService
        self.data = CurrentValueSubject(nil)
        self.nodeUsage = data.compactMap { $0 }.eraseToAnyPublisher()
        Task {
            try await setupInitialState()
        }
    }
    
    // MARK: - Private
        
    private func setupInitialState() async throws {
        stopSubscription()
        let nodeUsage = try await fileService.nodeUsage()
        data.value = nodeUsage
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
                data.value?.node.localBytesUsage = Int64(clamping: eventData.localBytesUsage)
            case let .fileSpaceUsage(eventData):
                guard let spaceIndex = data.value?.spaces.firstIndex(where: { $0.spaceID == eventData.spaceID }) else { return }
                data.value?.spaces[spaceIndex].bytesUsage = Int64(clamping: eventData.bytesUsage)
            default:
                break
            }
        }
    }
}
