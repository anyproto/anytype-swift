import Foundation
import ProtobufMessages
import Combine

protocol FileLimitsStorageProtocol: AnyObject {
    var limits: AnyPublisher<FileLimits, Never> { get }
}

actor FileLimitsStorage: FileLimitsStorageProtocol {
    
    // MAKR: - DI
    
    private let fileService: FileActionsServiceProtocol
    
    // MARK: - State
    
    private var subscriptions = [AnyCancellable]()
    private var data: CurrentValueSubject<FileLimits?, Never>
    nonisolated let limits: AnyPublisher<FileLimits, Never>
    
    init(fileService: FileActionsServiceProtocol) {
        self.fileService = fileService
        self.data = CurrentValueSubject(nil)
        self.limits = data.compactMap { $0 }.eraseToAnyPublisher()
        Task {
            try await setupInitialState()
        }
    }
    
    // MARK: - Private
    
    private func setupInitialState() async throws {
        let limits = try await fileService.spaceUsage()
        data.value = limits
        setupSubscription()
    }
    
    private func setupSubscription() {
        EventBunchSubscribtion.default.addHandler { [weak self] events in
            await self?.handle(events: events)
        }.store(in: &subscriptions)
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
