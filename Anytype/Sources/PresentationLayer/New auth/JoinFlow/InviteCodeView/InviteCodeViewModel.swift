import SwiftUI

@MainActor
final class InviteCodeViewModel: JoinFlowInputProtocol {

    // MARK: - JoinFlowInputProtocol
    
    let title = Loc.Auth.JoinFlow.InterCode.title
    let description = Loc.Auth.JoinFlow.InterCode.description
    let placeholder = ""
    
    @Published var inputText: String {
        didSet {
            state.inviteCode = inputText
        }
    }
    @Published var inProgress = false

    // MARK: - JoinFlowInputProtocol
    
    private let state: JoinFlowState
    private weak var output: JoinFlowStepOutput?
    private let authService: AuthServiceProtocol
    private let seedService: SeedServiceProtocol
    
    init(
        state: JoinFlowState,
        output: JoinFlowStepOutput?,
        authService: AuthServiceProtocol,
        seedService: SeedServiceProtocol
    ) {
        self.state = state
        self.inputText = state.inviteCode
        self.output = output
        self.authService = authService
        self.seedService = seedService
    }
    
    func onNextAction() {
        createAccount()
    }
    
    private func createAccount() {
        Task { @MainActor in
            do {
                inProgress = true
                
                state.mnemonic = try await authService.createWallet()
                try await authService.createAccount(
                    name: "",
                    imagePath: "",
                    alphaInviteCode: state.inviteCode
                )
                try? seedService.saveSeed(state.mnemonic)
                
                createAccountSuccess()
            } catch {
                createAccountError()
            }
        }
    }
    
    private func createAccountSuccess() {
        inProgress = false
        output?.onNext()
    }
    
    private func createAccountError() {
        inProgress = false
    }
}
