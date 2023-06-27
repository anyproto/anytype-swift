import SwiftUI

@MainActor
final class KeyPhraseViewModel: ObservableObject {

    @Published var key: String
    @Published var keyShown: Bool {
        didSet {
            state.keyShown = keyShown
        }
    }
    let state: JoinFlowState
    
    private weak var output: JoinFlowStepOutput?
    private let alertOpener: AlertOpenerProtocol
    private let localAuthService: LocalAuthServiceProtocol
    
    init(
        state: JoinFlowState,
        output: JoinFlowStepOutput?,
        alertOpener: AlertOpenerProtocol,
        localAuthService: LocalAuthServiceProtocol
    ) {
        self.state = state
        self.key = state.mnemonic.capitalized
        self.keyShown = state.keyShown
        self.output = output
        self.alertOpener = alertOpener
        self.localAuthService = localAuthService
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenOnboarding(step: .phrase)
    }
    
    func onPrimaryButtonTap() {
        if keyShown {
            output?.onNext()
        } else {
            localAuthService.auth(reason: Loc.accessToSecretPhraseFromKeychain) { didComplete in
                guard didComplete else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.keyShown = true
                }
            }
        }
    }
    
    func onSecondaryButtonTap() {
        output?.onNext()
    }
    
    func onCopyButtonTap() {
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = state.mnemonic
        alertOpener.showTopAlert(message: Loc.copied)
    }
}
