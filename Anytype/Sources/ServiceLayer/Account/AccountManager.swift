import Foundation
import ProtobufMessages
import Combine
import Services
import AnytypeCore

protocol AccountManagerProtocol: AnyObject, Sendable {
    var account: AccountData { get set }
    var accountPublisher: AnyPublisher<AccountData, Never> { get }
}

final class AccountManager: AccountManagerProtocol, Sendable {
    
    private let storage = AtomicPublishedStorage(AccountData.empty)
    
    var account: AccountData {
        get { storage.value }
        set { storage.value = newValue }
    }
    
    var accountPublisher: AnyPublisher<AccountData, Never> {
        return storage.publisher.removeDuplicates().eraseToAnyPublisher()
    }
    
    init() { }
}
