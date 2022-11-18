import Foundation
import SwiftUI

class CreateNewProfileViewModel: ObservableObject {
    
    private let windowManager: WindowManager
    private let authService: AuthServiceProtocol
    private let seedService: SeedServiceProtocol

    init(
        windowManager: WindowManager,
        authService: AuthServiceProtocol,
        seedService: SeedServiceProtocol
    ) {
        self.windowManager = windowManager
        self.authService = authService
        self.seedService = seedService
    }

    func showSetupWallet(signUpData: SignUpData, showWaitingView: Binding<Bool>) -> some View {
        let viewModel = WaitingOnCreatAccountViewModel(
            signUpData: signUpData,
            showWaitingView: showWaitingView,
            windowManager: windowManager,
            authService: authService,
            seedService: seedService
        )
        return WaitingOnCreatAccountView(viewModel: viewModel)
    }
    
    func setImage(signUpData: SignUpData, itemProvider: NSItemProvider?) {
        guard let itemProvider = itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
            DispatchQueue.main.async {
                signUpData.image = image as? UIImage
            }
        }
    }
}
