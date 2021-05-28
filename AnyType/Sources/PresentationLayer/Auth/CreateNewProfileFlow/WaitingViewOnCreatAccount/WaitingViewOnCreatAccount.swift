import SwiftUI

struct WaitingViewOnCreatAccount: View {
    @ObservedObject var viewModel: WaitingViewOnCreatAccountModel
    
    var body: some View {
        VStack {
            WaitingView(text: "Setting up the wallet…", errorState: !viewModel.error.isNil, errorText: viewModel.error)
        }
        .onAppear {
            self.viewModel.createAccount()
        }
    }
}
