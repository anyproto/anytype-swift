import Foundation
import ProtobufMessages
import Combine

protocol AccountManagerProtocol: AnyObject {
    var account: AccountData { get set }
    var accountPublisher: AnyPublisher<AccountData, Never> { get }
}

final class AccountManager: AccountManagerProtocol {
    
    @Published var account = AccountData.empty
    
    var accountPublisher: AnyPublisher<AccountData, Never> {
        return $account.eraseToAnyPublisher()
    }
    
    init() { }
}
