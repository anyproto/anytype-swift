import SwiftUI

@MainActor
protocol JoinFlowCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class JoinFlowCoordinator: JoinFlowCoordinatorProtocol, JoinFlowOutput {
    
    // MARK: - DI
    
    private let keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol
    
    init(
        keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol
    ) {
        self.keyViewModuleAssembly = keyViewModuleAssembly
    }
    
    // MARK: - JoinFlowCoordinatorProtocol
    
    func startFlow() -> AnyView {
        JoinFlowView(output: self).eraseToAnyView()
    }
    
    // MARK: - JoinFlowOutput
    
    func onStepChanged(_ step: JoinFlowStep, state: JoinFlowState, output: JoinFlowStepOutput) -> AnyView {
        switch step {
        case .soul:
            return SoulView(state: state, output: output).eraseToAnyView()
        case .key:
            return keyViewModuleAssembly.make(state: state, output: output)
        }
    }
    
    func keyPhraseMoreInfo() -> AnyView {
        KeyPhraseMoreInfoView().eraseToAnyView()
    }
}
