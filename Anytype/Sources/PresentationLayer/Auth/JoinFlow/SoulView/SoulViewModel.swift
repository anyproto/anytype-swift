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
    
    @Injected(\.accountManager)
    private var accountManager: AccountManagerProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: ObjectActionsServiceProtocol
    @Injected(\.workspaceService)
    private var workspaceService: WorkspaceServiceProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    init(state: JoinFlowState, output: JoinFlowStepOutput?) {
        self.state = state
        self.inputText = state.soul
        self.output = output
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenOnboarding(step: .offline)
    }
    
    func onNextAction() {
        updateNames()
    }
    
    // MARK: - Update names step
    
    private func onSuccess() {
        stopLoading()
        UIApplication.shared.hideKeyboard()
        output?.onNext()
    }
    
    private func updateNameError(_ error: Error) {
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
                updateNameError(error)
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
