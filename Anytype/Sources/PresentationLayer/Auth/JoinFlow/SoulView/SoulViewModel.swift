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
    @Published var generatedNamePlaceholder = ""
    
    // MARK: - DI
    
    private let state: JoinFlowState
    private weak var output: (any JoinFlowStepOutput)?
    
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.participantsStorage)
    private var accountParticipantStorage: any ParticipantsStorageProtocol
    
    init(state: JoinFlowState, output: (any JoinFlowStepOutput)?) {
        self.state = state
        self.inputText = state.soul
        self.output = output
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenOnboarding(step: .soul)
    }
    
    func onNextAction() {
        updateNames()
    }
    
    func startParticipantTask() async {
        for await participant in accountParticipantStorage.participantPublisher(spaceId: accountManager.account.info.accountSpaceId).values {
            generatedNamePlaceholder = participant.localName
        }
    }
    
    // MARK: - Update names step
    
    private func onSuccess() {
        stopLoading()
        UIApplication.shared.hideKeyboard()
        output?.onNext()
    }
    
    private func updateNameError(_ error: some Error) {
        stopLoading()
        output?.onError(error)
    }
    
    private func updateNames() {
        guard state.soul.isNotEmpty else {
            onSuccess()
            return
        }
        
        Task {
            startLoading()
            
            do {
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
