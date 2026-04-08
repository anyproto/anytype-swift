import SwiftUI

@MainActor
@Observable
final class KeyPhraseViewModel {

    var key: String
    var keyShown: Bool {
        didSet {
            state.keyShown = keyShown
        }
    }
    var showMoreInfo = false
    var snackBar: ToastBarData?

    @ObservationIgnored
    let state: JoinFlowState

    @ObservationIgnored
    private weak var output: (any JoinFlowStepOutput)?
    
    init(
        state: JoinFlowState,
        output: (any JoinFlowStepOutput)?
    ) {
        self.state = state
        self.key = state.mnemonic
        self.keyShown = state.keyShown
        self.output = output
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

    func onPhraseTap() {
        if keyShown {
            copy()
        } else {
            keyShown = true
        }
    }
    
    func keyPhraseMoreInfo() -> AnyView? {
        AnytypeAnalytics.instance().logClickOnboarding(step: .phrase, button: .moreInfo)
        return output?.keyPhraseMoreInfo()
    }
    
    private func copy() {
        AnytypeAnalytics.instance().logClickOnboarding(step: .phrase, button: .showAndCopy)
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = state.mnemonic
        snackBar = ToastBarData(Loc.copied)
    }
}
