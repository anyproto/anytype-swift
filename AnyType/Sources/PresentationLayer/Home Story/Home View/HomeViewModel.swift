import SwiftUI
import Combine
import BlocksModels

class HomeViewModel: ObservableObject {
    @ObservedObject var accountData = AccountInfoDataAccessor(profileService: ProfileService())
    
    private var profileViewModelObjectWillChange: AnyCancellable?

    let coordinator = HomeCoordinator(profileAssembly: ProfileAssembly())

    init() {
        self.profileViewModelObjectWillChange = accountData.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func obtainAccountInfo() {
        self.accountData.obtainAccountInfo()
    }
}
