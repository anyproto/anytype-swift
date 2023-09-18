import SwiftUI

@MainActor
final class KeyPhraseViewModel: ObservableObject {

    @Published var key: String
    @Published var keyShown: Bool {
        didSet {
            state.keyShown = keyShown
        }
    }
    @Published var showMoreInfo = false
    let state: JoinFlowState
    
    private weak var output: JoinFlowStepOutput?
    private let alertOpener: AlertOpenerProtocol
    
    init(
        state: JoinFlowState,
        output: JoinFlowStepOutput?,
        alertOpener: AlertOpenerProtocol
    ) {
        self.state = state
        self.key = state.mnemonic
        self.keyShown = state.keyShown
        self.output = output
        self.alertOpener = alertOpener
    }
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenOnboarding(step: .phrase)
    }
    
    func onPrimaryButtonTap() {
        if keyShown {
            output?.onNext()
        } else {
            AnytypeAnalytics.instance().logClickOnboarding(step: .phrase, button: .showAndCopy)
            keyShown = true
        }
    }
    
    func onSecondaryButtonTap() {
        AnytypeAnalytics.instance().logClickOnboarding(step: .phrase, button: .checkLater)
        output?.onNext()
    }
    
    func onCopyButtonTap() {
        AnytypeAnalytics.instance().logClickOnboarding(step: .phrase, button: .showAndCopy)
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = state.mnemonic
        alertOpener.showTopAlert(message: Loc.copied)
    }
    
    func keyPhraseMoreInfo() -> AnyView? {
        AnytypeAnalytics.instance().logClickOnboarding(step: .phrase, button: .moreInfo)
        return output?.keyPhraseMoreInfo()
    }
}
