import SwiftUI

@MainActor
final class VoidViewModel: ObservableObject {
    
    private let state: JoinFlowState
    private weak var output: JoinFlowStepOutput?
    private let authService: AuthServiceProtocol
    private let seedService: SeedServiceProtocol
    private let usecaseService: UsecaseServiceProtocol
    
    @Published var creatingAccountInProgress = false
    @Published var errorText: String? {
        didSet {
            showError = errorText.isNotNil
        }
    }
    @Published var showError: Bool = false
    
    init(
        state: JoinFlowState,
        output: JoinFlowStepOutput?,
        authService: AuthServiceProtocol,
        seedService: SeedServiceProtocol,
        usecaseService: UsecaseServiceProtocol
    ) {
        self.state = state
        self.output = output
        self.authService = authService
        self.seedService = seedService
        self.usecaseService = usecaseService
    }
    
    func onNextButtonTap() {
        createAccount()
    }
    
    private func createAccount() {
        Task { @MainActor in
            do {
                creatingAccountInProgress = true
                
                state.mnemonic = try await authService.createWallet()
                try await authService.createAccount(
                    name: "",
                    imagePath: ""
                )
                try await usecaseService.setObjectImportUseCaseToSkip()
                try? seedService.saveSeed(state.mnemonic)
                
                createAccountSuccess()
            } catch {
                createAccountError(error)
            }
        }
    }
    
    private func createAccountSuccess() {
        creatingAccountInProgress = false
        output?.onNext()
    }
    
    private func createAccountError(_ error: Error) {
        creatingAccountInProgress = false
        errorText = error.localizedDescription
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenOnboarding(step: .void)
    }
}
