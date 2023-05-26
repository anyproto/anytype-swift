import Foundation
import ProtobufMessages
import Combine

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
        
        cancellable = NotificationCenter.Publisher(
            center: .default,
            name: .middlewareEvent,
            object: nil
        )
        .compactMap { $0.object as? EventsBunch }
        .map(\.middlewareEvents)
        .receiveOnMain()
        .sink { [weak self] events in
            events.forEach { self?.handleEvent($0) }
        }
    }
    
    func stopSubscription() {
        cancellable = nil
    }
    
    // MARK: - Private
    
    private func handleEvent(_ event: Anytype_Event.Message) {
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
    
    private func handleStatus(_ newStatus: AccountStatus) {
        
        let currentStatus = accountManager.account.status
        guard currentStatus != newStatus else { return }
        accountManager.account.status = newStatus
        
        accountStatusSubject.send(newStatus)
    }
}
