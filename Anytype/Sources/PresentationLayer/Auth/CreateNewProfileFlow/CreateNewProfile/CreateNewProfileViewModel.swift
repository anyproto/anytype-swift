import Foundation
import SwiftUI

class CreateNewProfileViewModel: ObservableObject {
    
    private let applicationStateService: ApplicationStateServiceProtocol
    private let authService: AuthServiceProtocol
    private let seedService: SeedServiceProtocol

    init(
        applicationStateService: ApplicationStateServiceProtocol,
        authService: AuthServiceProtocol,
        seedService: SeedServiceProtocol
    ) {
        self.applicationStateService = applicationStateService
        self.authService = authService
        self.seedService = seedService
    }

    func showSetupWallet(signUpData: SignUpData, showWaitingView: Binding<Bool>) -> some View {
        let viewModel = WaitingOnCreatAccountViewModel(
            signUpData: signUpData,
            showWaitingView: showWaitingView,
            applicationStateService: applicationStateService,
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
