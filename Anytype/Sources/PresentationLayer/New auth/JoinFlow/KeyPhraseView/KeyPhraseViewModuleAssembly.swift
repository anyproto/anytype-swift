import SwiftUI

protocol KeyPhraseViewModuleAssemblyProtocol {
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView
}

final class KeyPhraseViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    private let serviceLocator: ServiceLocator

    init(uiHelpersDI: UIHelpersDIProtocol, serviceLocator: ServiceLocator) {
        self.uiHelpersDI = uiHelpersDI
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - KeyViewModuleAssemblyProtocol
    
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView  {
        return KeyPhraseView(
            model: KeyPhraseViewModel(
                state: state,
                output: output,
                alertOpener: uiHelpersDI.alertOpener(),
                localAuthService: serviceLocator.localAuthService()
            )
        ).eraseToAnyView()
    }
}
