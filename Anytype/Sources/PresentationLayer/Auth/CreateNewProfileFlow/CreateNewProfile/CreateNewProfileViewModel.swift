import Foundation
import SwiftUI

class CreateNewProfileViewModel: ObservableObject {
    private let seedService: SeedServiceProtocol

    init(seedService: SeedServiceProtocol) {
        self.seedService = seedService
    }

    func showSetupWallet(signUpData: SignUpData, showWaitingView: Binding<Bool>) -> some View {
        try? seedService.saveSeed(signUpData.mnemonic)

        return WaitingOnCreatAccountView(
            viewModel: WaitingOnCreatAccountViewModel(
                signUpData: signUpData,
                showWaitingView: showWaitingView
            )
        )
    }
}
