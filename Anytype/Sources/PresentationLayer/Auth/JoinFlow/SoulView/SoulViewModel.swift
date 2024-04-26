import SwiftUI
import Services

@MainActor
final class SoulViewModel: ObservableObject {
    
    @Published var inputText: String {
        didSet {
            state.soul = inputText
        }
    }
    @Published var inProgress = false
    
    // MARK: - DI
    
    private let state: JoinFlowState
    private weak var output: JoinFlowStepOutput?
    private let accountManager: AccountManagerProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let authService: AuthServiceProtocol
    private let seedService: SeedServiceProtocol
    private let usecaseService: UsecaseServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    init(
        state: JoinFlowState,
        output: JoinFlowStepOutput?,
        accountManager: AccountManagerProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        authService: AuthServiceProtocol,
        seedService: SeedServiceProtocol,
        usecaseService: UsecaseServiceProtocol,
        workspaceService: WorkspaceServiceProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.state = state
        self.inputText = state.soul
        self.output = output
        self.accountManager = accountManager
        self.objectActionsService = objectActionsService
        self.authService = authService
        self.seedService = seedService
        self.usecaseService = usecaseService
        self.workspaceService = workspaceService
        self.activeWorkspaceStorage = activeWorkspaceStorage
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenOnboarding(step: .void)
    }
    
    func onNextAction() {
        if state.mnemonic.isEmpty {
            createAccount()
        } else {
            updateNames()
        }
    }
    
    // MARK: - Create account step
    
    private func createAccount() {
        Task { @MainActor in
            startLoading()
            
            do {
                state.mnemonic = try await authService.createWallet()
                let account = try await authService.createAccount(
                    name: state.soul,
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
    
    private func createAccountError(_ error: Error) {
        stopLoading()
        output?.onError(error)
    }
    
    private func updateNames() {
        guard accountManager.account.name != state.soul else {
            onSuccess()
            return
        }
        Task { @MainActor in
            startLoading()
            
            do {
                try await workspaceService.workspaceSetDetails(
                    spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
                    details: [.name(state.soul)]
                )
                try await objectActionsService.updateBundledDetails(
                    contextID: accountManager.account.info.profileObjectID,
                    details: [.name(state.soul)]
                )
                
                onSuccess()
            } catch {
                createAccountError(error)
            }
        }
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
