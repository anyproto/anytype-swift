import SwiftUI
import Services

@MainActor
final class VaultViewModel: ObservableObject {
    
    @Published var inProgress = false
    
    // MARK: - DI
    
    private let state: JoinFlowState
    private weak var output: (any JoinFlowStepOutput)?
    
    @Injected(\.authService)
    private var authService: any AuthServiceProtocol
    @Injected(\.seedService)
    private var seedService: any SeedServiceProtocol
    @Injected(\.usecaseService)
    private var usecaseService: any UsecaseServiceProtocol
    
    init(state: JoinFlowState, output: (any JoinFlowStepOutput)?) {
        self.state = state
        self.output = output
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenOnboarding(step: .vault)
    }
    
    func onNextAction() {
        if state.mnemonic.isEmpty {
            createAccount()
        } else {
            onSuccess()
        }
    }
    
    // MARK: - Create account step
    
    private func createAccount() {
        Task {
            AnytypeAnalytics.instance().logStartCreateAccount()
            startLoading()
            
            do {
                state.mnemonic = try await authService.createWallet()
                let account = try await authService.createAccount(
                    name: Loc.myFirstSpace,
                    imagePath: ""
                )
                try await usecaseService.setObjectImportDefaultUseCase(spaceId: account.info.accountSpaceId)
                try? seedService.saveSeed(state.mnemonic)
                
                onSuccess()
            } catch {
                createAccountError(error)
            }
        }
    }
    
    private func onSuccess() {
        stopLoading()
        UIApplication.shared.hideKeyboard()
        output?.onNext()
    }
    
    private func createAccountError(_ error: some Error) {
        stopLoading()
        output?.onError(error)
    }
    
    private func startLoading() {
        output?.disableBackAction(true)
        inProgress = true
    }
    
    private func stopLoading() {
        output?.disableBackAction(false)
        inProgress = false
    }
}
