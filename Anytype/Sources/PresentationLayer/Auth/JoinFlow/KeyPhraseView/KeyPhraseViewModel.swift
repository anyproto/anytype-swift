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
    @Published var snackBar = ToastBarData.empty
    
    let state: JoinFlowState
    
    private weak var output: JoinFlowStepOutput?
    
    init(
        state: JoinFlowState,
        output: JoinFlowStepOutput?
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
    
    func onCopyButtonTap() {
        AnytypeAnalytics.instance().logClickOnboarding(step: .phrase, button: .showAndCopy)
        UISelectionFeedbackGenerator().selectionChanged()
        UIPasteboard.general.string = state.mnemonic
        snackBar = .init(text: Loc.copied, showSnackBar: true)
    }
    
    func keyPhraseMoreInfo() -> AnyView? {
        AnytypeAnalytics.instance().logClickOnboarding(step: .phrase, button: .moreInfo)
        return output?.keyPhraseMoreInfo()
    }
}
