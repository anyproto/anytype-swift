import SwiftUI
import Services

@MainActor
final class EmailCollectionViewModel: ObservableObject {
    
    @Published var inputText: String {
        didSet {
            state.email = inputText
        }
    }
    @Published var inProgress = false
    @Published var saveEmailTaskId: String? = nil
    @Published var showIncorrectEmailError = false
    
    // MARK: - DI
    
    private let state: JoinFlowState
    private weak var output: (any JoinFlowStepOutput)?

    @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    
    init(state: JoinFlowState, output: (any JoinFlowStepOutput)?) {
        self.state = state
        self.inputText = state.email
        self.output = output
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenOnboarding(step: .email)
    }
    
    func onNextAction() {
        if state.email.isValidEmail() {
            showIncorrectEmailError = false
            saveEmailTaskId = UUID().uuidString
        } else {
            showIncorrectEmailError = true
        }
    }
    
    func onSkipAction() {
        AnytypeAnalytics.instance().logScreenOnboardingSkipEmail()
        onSuccess()
    }
    
    func saveEmail() async {
        startLoading()
        try? await membershipService.getVerificationEmail(email: state.email)
        AnytypeAnalytics.instance().logScreenOnboardingEnterEmail()
        onSuccess()
    }
    
    private func onSuccess() {
        stopLoading()
        UIApplication.shared.hideKeyboard()
        output?.onNext()
    }
    
    private func saveEmailError(_ error: some Error) {
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
