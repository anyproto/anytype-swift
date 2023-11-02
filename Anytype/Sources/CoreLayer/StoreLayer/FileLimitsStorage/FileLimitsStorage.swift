import Foundation
import ProtobufMessages
import Combine

protocol FileLimitsStorageProtocol: AnyObject {
    func setupSpaceId(spaceId: String)
    var nodeUsage: AnyPublisher<NodeUsageInfo, Never> { get }
}

actor FileLimitsStorage: FileLimitsStorageProtocol {
    
    // MAKR: - DI
    
    private let fileService: FileActionsServiceProtocol
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var data: CurrentValueSubject<NodeUsageInfo?, Never>
    private var spaceId: String?
    nonisolated let nodeUsage: AnyPublisher<NodeUsageInfo, Never>
    
    init(fileService: FileActionsServiceProtocol) {
        self.fileService = fileService
        self.data = CurrentValueSubject(nil)
        self.nodeUsage = data.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    // MARK: - Private
    
    nonisolated
    func setupSpaceId(spaceId: String) {
        Task {
            try await setupInitialState(spaceId: spaceId)
        }
    }
    
    private func setupInitialState(spaceId newSpaceId: String) async throws {
        stopSubscription()
        spaceId = newSpaceId
        let nodeUsage = try await fileService.nodeUsage()
        data.value = nodeUsage
        setupSubscription()
    }
    
    private func setupSubscription() {
        EventBunchSubscribtion.default.addHandler { [weak self] events in
            await self?.handle(events: events)
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
