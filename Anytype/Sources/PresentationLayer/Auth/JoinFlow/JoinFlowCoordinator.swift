import SwiftUI

@MainActor
protocol JoinFlowCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class JoinFlowCoordinator: JoinFlowCoordinatorProtocol, JoinFlowOutput {
    
    // MARK: - DI
    
    private let joinFlowModuleAssembly: JoinFlowModuleAssemblyProtocol
    private let keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol
    private let keyPhraseMoreInfoViewModuleAssembly: KeyPhraseMoreInfoViewModuleAssemblyProtocol
    private let soulViewModuleAssembly: SoulViewModuleAssemblyProtocol
    
    init(
        joinFlowModuleAssembly: JoinFlowModuleAssemblyProtocol,
        keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol,
        keyPhraseMoreInfoViewModuleAssembly: KeyPhraseMoreInfoViewModuleAssemblyProtocol,
        soulViewModuleAssembly: SoulViewModuleAssemblyProtocol
    ) {
        self.joinFlowModuleAssembly = joinFlowModuleAssembly
        self.keyViewModuleAssembly = keyViewModuleAssembly
        self.keyPhraseMoreInfoViewModuleAssembly = keyPhraseMoreInfoViewModuleAssembly
        self.soulViewModuleAssembly = soulViewModuleAssembly
    }
    
    // MARK: - JoinFlowCoordinatorProtocol
    
    func startFlow() -> AnyView {
        joinFlowModuleAssembly.make(output: self)
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
        keyPhraseMoreInfoViewModuleAssembly.make()
    }
}
