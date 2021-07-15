import Foundation
import SwiftUI
import Amplitude


class MainAuthViewModel: ObservableObject {
    private let authService = ServiceLocator.shared.authService()
    
    var error: String = "" {
        didSet {
            if !error.isEmpty {
                isShowingError = true
            }
        }
    }
    @Published var isShowingError: Bool = false
    @Published var showSignUpFlow: Bool = false
    
    func singUp() {
        authService.createWallet() { [weak self] result in
            switch result {
            case .failure(let error):
                // TODO: handel error
                self?.error = error.localizedDescription
            case .success:
                self?.showSignUpFlow = true
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.walletCreate)
            }
        }
    }
    
    // MARK: - Coordinator
    func signUpFlow() -> some View {
        return AlphaInviteCodeView(signUpData: SignUpData())
    }
    
    func loginView() -> some View {
        return LoginView(viewModel: LoginViewModel())
    }

    // MARK: - View output
    func viewLoaded() {
        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.showAuthScreen)
    }
}
