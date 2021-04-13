import SwiftUI
import Combine
import BlocksModels

class HomeViewModel: ObservableObject {
    @ObservedObject var accountData = AccountInfoDataAccessor()
    private var accountDataWillChange: AnyCancellable?

    let coordinator: HomeCoordinator

    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
        
        self.accountDataWillChange = accountData.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func obtainAccountInfo() {
        self.accountData.obtainAccountInfo()
    }
}
