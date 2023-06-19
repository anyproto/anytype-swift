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
        NotificationCenter.Publisher(
            center: .default,
            name: .middlewareEvent,
            object: nil
        )
        .compactMap { $0.object as? EventsBunch }
        .map(\.middlewareEvents)
        .sink { [weak self] events in
            Task { [weak self] in
                for event in events {
                    await self?.handleEvent(event)
                }
            }
        }
        .store(in: &subscriptions)
    }
    
    private func handleEvent(_ event: Anytype_Event.Message) async {
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
