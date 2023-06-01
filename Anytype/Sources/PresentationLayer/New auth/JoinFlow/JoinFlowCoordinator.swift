import SwiftUI

@MainActor
protocol JoinFlowCoordinatorProtocol {
    func startFlow(with state: JoinFlowState) -> AnyView
}

@MainActor
final class JoinFlowCoordinator: JoinFlowCoordinatorProtocol, JoinFlowOutput {
    
    // MARK: - DI
    
    private let joinFlowModuleAssembly: JoinFlowModuleAssemblyProtocol
    private let inviteCodeViewModuleAssembly: InviteCodeViewModuleAssemblyProtocol
    private let voidViewModuleAssembly: VoidViewModuleAssemblyProtocol
    private let keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol
    private let soulViewModuleAssembly: SoulViewModuleAssemblyProtocol
    private let creatingSoulViewModuleAssembly: CreatingSoulViewModuleAssemblyProtocol
    
    init(
        joinFlowModuleAssembly: JoinFlowModuleAssemblyProtocol,
        inviteCodeViewModuleAssembly: InviteCodeViewModuleAssemblyProtocol,
        voidViewModuleAssembly: VoidViewModuleAssemblyProtocol,
        keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol,
        soulViewModuleAssembly: SoulViewModuleAssemblyProtocol,
        creatingSoulViewModuleAssembly: CreatingSoulViewModuleAssemblyProtocol
    ) {
        self.joinFlowModuleAssembly = joinFlowModuleAssembly
        self.inviteCodeViewModuleAssembly = inviteCodeViewModuleAssembly
        self.voidViewModuleAssembly = voidViewModuleAssembly
        self.keyViewModuleAssembly = keyViewModuleAssembly
        self.soulViewModuleAssembly = soulViewModuleAssembly
        self.creatingSoulViewModuleAssembly = creatingSoulViewModuleAssembly
    }
    
    // MARK: - JoinFlowCoordinatorProtocol
    
    func startFlow(with state: JoinFlowState) -> AnyView {
        joinFlowModuleAssembly.make(state: state, output: self)
    }
    
    // MARK: - JoinFlowOutput
    
    func onStepChanged(_ step: JoinFlowStep, state: JoinFlowState, output: JoinFlowStepOutput) -> AnyView {
        switch step {
        case .code:
            return inviteCodeViewModuleAssembly.make(state: state, output: output)
        case .void:
            return voidViewModuleAssembly.make(output: output)
        case .key:
            return keyViewModuleAssembly.make(state: state, output: output)
        case .soul:
            return soulViewModuleAssembly.make(state: state, output: output)
        case .creatingSoul:
            return creatingSoulViewModuleAssembly.make(state: state, output: output)
        }
    }
}
