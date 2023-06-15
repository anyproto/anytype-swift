import Foundation
import SwiftUI

class MainAuthViewModel: ObservableObject {
    private let authService = ServiceLocator.shared.authService()
    private let applicationStateService: ApplicationStateServiceProtocol
    
    init(applicationStateService: ApplicationStateServiceProtocol) {
        self.applicationStateService = applicationStateService
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
        do {
            let mnemonic = try authService.createWallet()
            enteredMnemonic = mnemonic
            showSignUpFlow = true
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    // MARK: - Coordinator
    func signUpFlow() -> some View {
        let viewModel = CreateNewProfileViewModel(
            applicationStateService: applicationStateService,
            authService: ServiceLocator.shared.authService(),
            seedService: ServiceLocator.shared.seedService(),
            usecaseService: ServiceLocator.shared.usecaseService(),
            metricsService: ServiceLocator.shared.metricsService()
        )
        return CreateNewProfileView(
            viewModel: viewModel,
            signUpData: SignUpData(mnemonic: self.enteredMnemonic)
        )
    }
    
    func loginView() -> some View {
        let viewModel = LoginViewModel(applicationStateService: applicationStateService)
        return LoginView(viewModel: viewModel)
    }

    // MARK: - View output
    func viewLoaded() {
        AnytypeAnalytics.instance().logScreenAuthRegistration()
    }
}
