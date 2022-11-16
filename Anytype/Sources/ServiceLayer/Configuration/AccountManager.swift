import Foundation
import ProtobufMessages

final class AccountManager: ObservableObject {
    static let shared = AccountManager()
    
    @Published var account = AccountData.empty
    
    init() { }
    
    // TODO: Handle all account events in one place - https://linear.app/anytype/issue/IOS-676
//    private func handleAccountUpdate(_ update: Anytype_Event.Account.Update) {
//        let currentStatus = AccountManager.shared.account.status
//        let newStatus = AccountManager.shared.account.status
//        guard currentStatus != newStatus else { return }
//
//        switch newStatus {
//        case .active:
//            break
//        case .pendingDeletion(let deadline):
//            break
//            Task { @MainActor in
//                WindowManager.shared.showDeletedAccountWindow(deadline: deadline)
//            }
//        case .deleted:
//            break
//            if UserDefaultsConfig.usersId.isNotEmpty {
//                ServiceLocator.shared.authService().logout(removeData: true) { _ in }
//                WindowManager.shared.showAuthWindow()
//            }
//        }
//    }
}
