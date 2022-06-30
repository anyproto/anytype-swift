import Foundation
import ProtobufMessages

final class AccountManager: ObservableObject {
    static let shared = AccountManager()
    
    @Published var account = AccountData.empty
    
    init() { }
    
    #warning("TODO: Remove after middleware update")
    func updateAccount(_ update: Anytype_Event.Account.Update) {
        self.account = AccountData(
            id: account.id,
            name: account.name,
            avatar: account.avatar,
            config: update.config.asModel,
            status: update.status.asModel ?? account.status,
            info: account.info
        )
    }
}
