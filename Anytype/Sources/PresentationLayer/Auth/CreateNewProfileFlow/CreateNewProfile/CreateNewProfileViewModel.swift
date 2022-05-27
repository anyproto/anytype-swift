import Foundation
import SwiftUI

class CreateNewProfileViewModel: ObservableObject {
    private let seedService: SeedServiceProtocol

    init(seedService: SeedServiceProtocol) {
        self.seedService = seedService
    }

    func showSetupWallet(signUpData: SignUpData, showWaitingView: Binding<Bool>) -> some View {
        return WaitingOnCreatAccountView(
            viewModel: WaitingOnCreatAccountViewModel(
                signUpData: signUpData,
                showWaitingView: showWaitingView,
                seedService: self.seedService
            )
        )
    }
}
