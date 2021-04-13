import SwiftUI
import Combine
import BlocksModels

class HomeViewModel: ObservableObject {
    @ObservedObject var accountData = AccountInfoDataAccessor(profileService: ProfileService())
    private var accountDataWillChange: AnyCancellable?

    let coordinator = HomeCoordinator(profileAssembly: ProfileAssembly())

    init() {
        self.accountDataWillChange = accountData.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func obtainAccountInfo() {
        self.accountData.obtainAccountInfo()
    }
}
