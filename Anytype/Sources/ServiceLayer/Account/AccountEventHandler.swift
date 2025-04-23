import Foundation
import ProtobufMessages
@preconcurrency import Combine
import Services

protocol AccountEventHandlerProtocol: Sendable {
    func startSubscription() async
    func stopSubscription() async
    
    var accountShowPublisher: AnyPublisher<String, Never> { get async }
    var accountStatusPublisher: AnyPublisher<AccountStatus, Never> { get async }
}

actor AccountEventHandler: AccountEventHandlerProtocol {
    
    private var cancellable: AnyCancellable?
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    
    private let accountShowSubject = PassthroughSubject<String, Never>()
    private let accountStatusSubject = PassthroughSubject<AccountStatus, Never>()
    
    // MARK: - AccountEventHandlerProtocol
    
    var accountShowPublisher: AnyPublisher<String, Never> {
        return accountShowSubject.eraseToAnyPublisher()
    }
    
    var accountStatusPublisher: AnyPublisher<AccountStatus, Never> {
        return accountStatusSubject.eraseToAnyPublisher()
    }
    
    func startSubscription() {
        guard cancellable == nil else { return }
        
        cancellable = EventBunchSubscribtion.default.addHandler { [weak self] events in
            await self?.handle(events: events)
        }
    }
    
    func stopSubscription() {
        cancellable = nil
    }
    
    // MARK: - Private
    
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case let .accountShow(data):
                accountShowSubject.send(data.account.id)
            case let .accountUpdate(data):
                if data.hasStatus, let status = try? data.status.asModel() {
                    handleStatus(status)
                }
                // Other account events
            case .accountDetails,
                    .accountConfigUpdate:
                break
            default:
                break
            }
        }
    }
    
    private func handleStatus(_ newStatus: AccountStatus) {
        
        let currentStatus = accountManager.account.status
        guard currentStatus != newStatus else { return }
        accountManager.account.status = newStatus
        
        accountStatusSubject.send(newStatus)
    }
}
