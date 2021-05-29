import Foundation
import SwiftUI


class CreateNewProfileViewModel: ObservableObject {    
    func showSetupWallet(signUpData: SignUpData, showWaitingView: Binding<Bool>) -> some View {
        return WaitingViewOnCreatAccount(
            viewModel: WaitingViewOnCreatAccountModel(
                signUpData: signUpData,
                showWaitingView: showWaitingView
            )
        )
    }
}
