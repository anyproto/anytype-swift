import SwiftUI

@MainActor
final class JoinViewModel: ObservableObject, JoinBaseOutput {
    
    @Published var step: JoinStep = JoinStep.firstStep
    @Published var forward = true
    @Published var errorText: String? {
        didSet {
            showError = errorText.isNotNil
        }
    }
    @Published var showError: Bool = false
    @Published var disableBackAction: Bool = false
    @Published var dismiss = false
    
    let state: JoinFlowState
    
    @Injected(\.applicationStateService)
    private var applicationStateService: any ApplicationStateServiceProtocol
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.serverConfigurationStorage)
    private var serverConfigurationStorage: any ServerConfigurationStorageProtocol
    
    init(state: JoinFlowState) {
        self.state = state
    }
    
    func onBackButtonTap() {
        if step.previous.isNil {
            dismiss.toggle()
        } else {
            onBack()
        }
    }
    
    // MARK: - JoinBaseOutput
    
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
    
    private func finishFlow() {
        applicationStateService.state = .home
        AnytypeAnalytics.instance().logAccountOpen(
            analyticsId: accountManager.account.info.analyticsId
        )
    }
    
    private func shouldSkipEmailStep() -> Bool {
        serverConfigurationStorage.currentConfiguration() == .localOnly
    }
}
