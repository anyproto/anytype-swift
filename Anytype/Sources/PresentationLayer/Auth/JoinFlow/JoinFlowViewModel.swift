import SwiftUI

@MainActor
final class JoinFlowViewModel: ObservableObject, JoinFlowStepOutput {
    
    @Published var step: JoinFlowStep = JoinFlowStep.firstStep
    @Published var forward = true
    @Published var errorText: String? {
        didSet {
            showError = errorText.isNotNil
        }
    }
    @Published var showError: Bool = false
    @Published var disableBackAction: Bool = false
    @Published var hideContent = false
    
    private let state: JoinFlowState
    
    private weak var output: (any JoinFlowOutput)?
    @Injected(\.applicationStateService)
    private var applicationStateService: any ApplicationStateServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.serverConfigurationStorage)
    private var serverConfigurationStorage: any ServerConfigurationStorageProtocol
    
    init(state: JoinFlowState, output: (any JoinFlowOutput)?) {
        self.state = state
        self.output = output
    }
    
    func content() -> AnyView? {
        output?.onStepChanged(step, state: state, output: self)
    }
    
    // MARK: - JoinStepOutput
    
    func onNext() {
        guard let nextStep = step.next else {
            finishFlow()
            return
        }
        
        if nextStep == .email && shouldSkipEmailStep() {
            finishFlow()
            return
        }
        
        forward = true
        
        withAnimation {
            step = nextStep
        }
    }
    
    func onBack() {
        guard let previousStep = step.previous else { return }
        
        UIApplication.shared.hideKeyboard()
        forward = false
        
        withAnimation {
            step = previousStep
        }
    }
    
    func onError(_ error: some Error) {
        errorText = error.localizedDescription
    }
    
    func disableBackAction(_ disable: Bool) {
        disableBackAction = disable
    }
    
    func keyPhraseMoreInfo() -> AnyView? {
        output?.keyPhraseMoreInfo()
    }
    
    private func finishFlow() {
        hideContent.toggle() // hack to avoid inappropriate animation when hiding
        applicationStateService.state = .home
        AnytypeAnalytics.instance().logAccountOpen(
            analyticsId: accountManager.account.info.analyticsId
        )
        if state.soul.isEmpty {
            AnytypeAnalytics.instance().logOnboardingSkipName()
        }
    }
    
    private func shouldSkipEmailStep() -> Bool {
        serverConfigurationStorage.currentConfiguration() == .localOnly
    }
}
