import SwiftUI

class AuthAssembly {
    func authView() -> some View {
        MainAuthView(viewModel: MainAuthViewModel())
    }
}
