import SwiftUI

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
    
    init(
        state: JoinFlowState,
        output: JoinFlowStepOutput?,
        accountManager: AccountManagerProtocol,
        objectActionsService: ObjectActionsServiceProtocol
    ) {
        self.state = state
        self.inputText = state.soul
        self.output = output
        self.accountManager = accountManager
        self.objectActionsService = objectActionsService
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenOnboarding(step: .soul)
    }
    
    func onNextAction() {
        inProgress = true
        updateProfileName()
        updateSpaceName()
        inProgress = false
        
        output?.onNext()
    }
    
    private func updateProfileName() {
        Task {
            try await objectActionsService.updateBundledDetails(
                contextID: accountManager.account.info.profileObjectID,
                details: [.name(state.soul)]
            )
        }
    }
    
    private func updateSpaceName() {
        Task {
            try await objectActionsService.updateBundledDetails(
                contextID: accountManager.account.info.accountSpaceId,
                details: [.name(state.soul)]
            )
        }
    }
}
