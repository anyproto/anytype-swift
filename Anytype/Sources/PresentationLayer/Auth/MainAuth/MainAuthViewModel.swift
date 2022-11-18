import Foundation
import SwiftUI

class MainAuthViewModel: ObservableObject {
    private let authService = ServiceLocator.shared.authService()
    private let windowManager: WindowManager
    
    init(windowManager: WindowManager) {
        self.windowManager = windowManager
    }
    
    var error: String = "" {
        didSet {
            if !error.isEmpty {
                isShowingError = true
            }
        }
    }
    var enteredMnemonic: String = ""

    @Published var isShowingError: Bool = false
    @Published var showSignUpFlow: Bool = false
    
    func singUp() {
        let result = authService.createWallet()
        switch result {
        case .failure(let error):
            self.error = error.localizedDescription
        case .success(let mnemonic):
            enteredMnemonic = mnemonic
            showSignUpFlow = true
        }
    }
    
    // MARK: - Coordinator
    func signUpFlow() -> some View {
        return AlphaInviteCodeView(signUpData: SignUpData(mnemonic: self.enteredMnemonic), windowManager: windowManager)
    }
    
    func loginView() -> some View {
        let viewModel = LoginViewModel(windowManager: windowManager)
        return LoginView(viewModel: viewModel)
    }

    // MARK: - View output
    func viewLoaded() {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.authScreenShow)
    }
}
