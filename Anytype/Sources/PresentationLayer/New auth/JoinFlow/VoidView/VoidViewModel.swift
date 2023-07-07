import SwiftUI

@MainActor
final class VoidViewModel: ObservableObject {
    
    @Published var creatingAccountInProgress = false
    
    private let state: JoinFlowState
    private weak var output: JoinFlowStepOutput?
    private let authService: AuthServiceProtocol
    private let seedService: SeedServiceProtocol
    private let usecaseService: UsecaseServiceProtocol
    
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
        Task {
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
        output?.onError(error)
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenOnboarding(step: .void)
    }
}
