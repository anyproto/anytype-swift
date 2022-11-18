import Foundation
import ProtobufMessages
import Combine

protocol AccountEventHandlerProtocol {
    func startSubscription()
    func stopSubscription()
}

final class AccountEventHandler: AccountEventHandlerProtocol {
    
    private var cancellable: AnyCancellable?
    private var accountManager: AccountManager
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
    }
    
    // MARK: - AccountEventHandlerProtocol
    
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
            if data.hasAccount {
                accountManager.account = data.account.asModel
            }
        case let .accountUpdate(data):
            if data.hasConfig {
                accountManager.account.config = data.config.asModel
            }
            if data.hasStatus, let status = data.status.asModel {
                accountManager.account.status = status
            }
        case let .accountDetails(data):
            break
        case let .accountConfigUpdate(data):
            if data.hasConfig {
                accountManager.account.config = data.config.asModel
            }
            if data.hasStatus, let status = data.status.asModel {
                accountManager.account.status = status
            }
        default:
            break
        }
    }
}
