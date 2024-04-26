import SwiftUI

protocol KeyPhraseViewModuleAssemblyProtocol {
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView
}

final class KeyPhraseViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol

    init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - KeyViewModuleAssemblyProtocol
    
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView  {
        return KeyPhraseView(
            model: KeyPhraseViewModel(
                state: state,
                output: output,
                alertOpener: self.uiHelpersDI.alertOpener()
            )
        ).eraseToAnyView()
    }
}
