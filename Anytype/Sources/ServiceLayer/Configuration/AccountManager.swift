import Foundation
import ProtobufMessages

final class AccountManager: ObservableObject {
    static let shared = AccountManager()
    
    @Published var account = AccountData.empty
    
    init() { }
}
