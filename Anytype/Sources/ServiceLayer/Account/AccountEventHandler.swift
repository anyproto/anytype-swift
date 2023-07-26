import Foundation
import ProtobufMessages
import Combine
import Services

protocol AccountEventHandlerProtocol {
    func startSubscription()
    func stopSubscription()
    
    var accountShowPublisher: AnyPublisher<String, Never> { get }
    var accountStatusPublisher: AnyPublisher<AccountStatus, Never> { get }
}

final class AccountEventHandler: AccountEventHandlerProtocol {
    
    private var cancellable: AnyCancellable?
    private var accountManager: AccountManagerProtocol
    
    private let accountShowSubject = PassthroughSubject<String, Never>()
    private let accountStatusSubject = PassthroughSubject<AccountStatus, Never>()
    
    init(accountManager: AccountManagerProtocol) {
        self.accountManager = accountManager
    }
    
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
    
    @MainActor
    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case let .accountShow(data):
                accountShowSubject.send(data.account.id)
            case let .accountUpdate(data):
                if data.hasStatus, let status = data.status.asModel {
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
