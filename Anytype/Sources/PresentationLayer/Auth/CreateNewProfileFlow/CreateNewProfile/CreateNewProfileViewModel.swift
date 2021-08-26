import Foundation
import SwiftUI


class CreateNewProfileViewModel: ObservableObject {    
    func showSetupWallet(signUpData: SignUpData, showWaitingView: Binding<Bool>) -> some View {
        return WaitingOnCreatAccountView(
            viewModel: WaitingOnCreatAccountViewModel(
                signUpData: signUpData,
                showWaitingView: showWaitingView
            )
        )
    }
}
