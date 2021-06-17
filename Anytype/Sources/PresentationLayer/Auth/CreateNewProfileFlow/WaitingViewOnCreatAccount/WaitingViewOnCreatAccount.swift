import SwiftUI

struct WaitingViewOnCreatAccount: View {
    @StateObject var viewModel: WaitingViewOnCreatAccountModel
    
    var body: some View {
        VStack {
            WaitingView(text: "Setting up the wallet…", showError: $viewModel.showError, errorText: $viewModel.error) {
                viewModel.showWaitingView = false
            }
        }
        .onAppear {
            self.viewModel.createAccount()
        }
    }
}
