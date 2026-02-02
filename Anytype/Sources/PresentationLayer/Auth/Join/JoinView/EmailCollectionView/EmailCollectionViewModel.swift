import SwiftUI
import Services

@MainActor
@Observable
final class EmailCollectionViewModel {

    var inputText: String {
        didSet {
            state.email = inputText
        }
    }
    var inProgress = false
    var saveEmailTaskId: String? = nil
    var showIncorrectEmailError = false

    // MARK: - DI

    @ObservationIgnored
    private let state: JoinFlowState
    @ObservationIgnored
    private weak var output: (any JoinBaseOutput)?

    @ObservationIgnored @Injected(\.membershipService)
    private var membershipService: any MembershipServiceProtocol
    
    init(state: JoinFlowState, output: (any JoinBaseOutput)?) {
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
        try? await membershipService.getVerificationEmailOnOnboarding(email: state.email)
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
