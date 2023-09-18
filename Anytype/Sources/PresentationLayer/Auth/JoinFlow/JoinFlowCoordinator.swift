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
    private let creatingSoulViewModuleAssembly: CreatingSoulViewModuleAssemblyProtocol
    
    init(
        joinFlowModuleAssembly: JoinFlowModuleAssemblyProtocol,
        keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol,
        keyPhraseMoreInfoViewModuleAssembly: KeyPhraseMoreInfoViewModuleAssemblyProtocol,
        soulViewModuleAssembly: SoulViewModuleAssemblyProtocol,
        creatingSoulViewModuleAssembly: CreatingSoulViewModuleAssemblyProtocol
    ) {
        self.joinFlowModuleAssembly = joinFlowModuleAssembly
        self.keyViewModuleAssembly = keyViewModuleAssembly
        self.keyPhraseMoreInfoViewModuleAssembly = keyPhraseMoreInfoViewModuleAssembly
        self.soulViewModuleAssembly = soulViewModuleAssembly
        self.creatingSoulViewModuleAssembly = creatingSoulViewModuleAssembly
    }
    
    // MARK: - JoinFlowCoordinatorProtocol
    
    func startFlow() -> AnyView {
        joinFlowModuleAssembly.make(output: self)
    }
    
    // MARK: - JoinFlowOutput
    
    func onStepChanged(_ step: JoinFlowStep, state: JoinFlowState, output: JoinFlowStepOutput) -> AnyView {
        switch step {
        case .creatingSoul:
            return creatingSoulViewModuleAssembly.make(state: state, output: output)
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
