import SwiftUI

protocol KeyPhraseViewModuleAssemblyProtocol {
    @MainActor
    func make(output: JoinFlowStepOutput?) -> AnyView
}

final class KeyPhraseViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol {
    
    // MARK: - KeyViewModuleAssemblyProtocol
    
    @MainActor
    func make(output: JoinFlowStepOutput?) -> AnyView {
        return KeyPhraseView(
            model: KeyPhraseViewModel(output: output)
        ).eraseToAnyView()
    }
}
