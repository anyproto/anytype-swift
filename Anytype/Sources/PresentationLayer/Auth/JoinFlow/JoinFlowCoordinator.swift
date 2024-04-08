import SwiftUI

@MainActor
protocol JoinFlowCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class JoinFlowCoordinator: JoinFlowCoordinatorProtocol, JoinFlowOutput {
    
    // MARK: - DI
    
    private let keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol
    private let soulViewModuleAssembly: SoulViewModuleAssemblyProtocol
    
    init(
        keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol,
        soulViewModuleAssembly: SoulViewModuleAssemblyProtocol
    ) {
        self.keyViewModuleAssembly = keyViewModuleAssembly
        self.soulViewModuleAssembly = soulViewModuleAssembly
    }
    
    // MARK: - JoinFlowCoordinatorProtocol
    
    func startFlow() -> AnyView {
        JoinFlowView(output: self).eraseToAnyView()
    }
    
    // MARK: - JoinFlowOutput
    
    func onStepChanged(_ step: JoinFlowStep, state: JoinFlowState, output: JoinFlowStepOutput) -> AnyView {
        switch step {
        case .soul:
            return soulViewModuleAssembly.make(state: state, output: output)
        case .key:
            return keyViewModuleAssembly.make(state: state, output: output)
        }
    }
    
    func keyPhraseMoreInfo() -> AnyView {
        KeyPhraseMoreInfoView().eraseToAnyView()
    }
}
