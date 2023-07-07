import SwiftUI

@MainActor
protocol JoinFlowCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class JoinFlowCoordinator: JoinFlowCoordinatorProtocol, JoinFlowOutput {
    
    // MARK: - DI
    
    private let joinFlowModuleAssembly: JoinFlowModuleAssemblyProtocol
    private let voidViewModuleAssembly: VoidViewModuleAssemblyProtocol
    private let keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol
    private let soulViewModuleAssembly: SoulViewModuleAssemblyProtocol
    private let creatingSoulViewModuleAssembly: CreatingSoulViewModuleAssemblyProtocol
    
    // MARK: - State
    
    private let state = JoinFlowState()
    
    init(
        joinFlowModuleAssembly: JoinFlowModuleAssemblyProtocol,
        voidViewModuleAssembly: VoidViewModuleAssemblyProtocol,
        keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol,
        soulViewModuleAssembly: SoulViewModuleAssemblyProtocol,
        creatingSoulViewModuleAssembly: CreatingSoulViewModuleAssemblyProtocol
    ) {
        self.joinFlowModuleAssembly = joinFlowModuleAssembly
        self.voidViewModuleAssembly = voidViewModuleAssembly
        self.keyViewModuleAssembly = keyViewModuleAssembly
        self.soulViewModuleAssembly = soulViewModuleAssembly
        self.creatingSoulViewModuleAssembly = creatingSoulViewModuleAssembly
    }
    
    // MARK: - JoinFlowCoordinatorProtocol
    
    func startFlow() -> AnyView {
        joinFlowModuleAssembly.make(output: self)
    }
    
    // MARK: - JoinFlowOutput
    
    func onStepChanged(_ step: JoinFlowStep, output: JoinFlowStepOutput) -> AnyView {
        switch step {
        case .void:
            return voidViewModuleAssembly.make(state: state, output: output)
        case .key:
            return keyViewModuleAssembly.make(state: state, output: output)
        case .soul:
            return soulViewModuleAssembly.make(state: state, output: output)
        case .creatingSoul:
            return creatingSoulViewModuleAssembly.make(state: state, output: output)
        }
    }
}
