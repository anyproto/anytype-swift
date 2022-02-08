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
        let result = authService.createWallet()
        switch result {
        case .failure(let error):
            self.error = error.localizedDescription
        case .success:
            showSignUpFlow = true
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
        Amplitude.instance().logEvent(AmplitudeEventsName.authScreenShow)
    }
}
