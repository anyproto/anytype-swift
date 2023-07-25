import Foundation
import ProtobufMessages
import Combine

protocol FileLimitsStorageProtocol: AnyObject {
    func setupSpaceId(spaceId: String)
    var limits: AnyPublisher<FileLimits, Never> { get }
}

actor FileLimitsStorage: FileLimitsStorageProtocol {
    
    // MAKR: - DI
    
    private let fileService: FileActionsServiceProtocol
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var data: CurrentValueSubject<FileLimits?, Never>
    private var spaceId: String?
    nonisolated let limits: AnyPublisher<FileLimits, Never>
    
    init(fileService: FileActionsServiceProtocol) {
        self.fileService = fileService
        self.data = CurrentValueSubject(nil)
        self.limits = data.compactMap { $0 }.eraseToAnyPublisher()
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
        let limits = try await fileService.spaceUsage(spaceId: newSpaceId)
        data.value = limits
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
                data.value?.localBytesUsage = Int64(eventData.localBytesUsage)
            case let .fileSpaceUsage(eventData):
                data.value?.bytesUsage = Int64(eventData.bytesUsage)
            default:
                break
            }
        }
    }
}
