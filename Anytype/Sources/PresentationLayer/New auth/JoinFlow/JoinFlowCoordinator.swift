import SwiftUI

@MainActor
protocol JoinFlowCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class JoinFlowCoordinator: JoinFlowCoordinatorProtocol, JoinFlowOutput {
    
    // MARK: - DI
    
    private let joinFlowModuleAssembly: JoinFlowModuleAssemblyProtocol
    private let inviteCodeViewModuleAssembly: InviteCodeViewModuleAssemblyProtocol
    private let voidViewModuleAssembly: VoidViewModuleAssemblyProtocol
    private let keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol
    
    init(
        joinFlowModuleAssembly: JoinFlowModuleAssemblyProtocol,
        inviteCodeViewModuleAssembly: InviteCodeViewModuleAssemblyProtocol,
        voidViewModuleAssembly: VoidViewModuleAssemblyProtocol,
        keyViewModuleAssembly: KeyPhraseViewModuleAssemblyProtocol
    ) {
        self.joinFlowModuleAssembly = joinFlowModuleAssembly
        self.inviteCodeViewModuleAssembly = inviteCodeViewModuleAssembly
        self.voidViewModuleAssembly = voidViewModuleAssembly
        self.keyViewModuleAssembly = keyViewModuleAssembly
    }
    
    // MARK: - JoinFlowCoordinatorProtocol
    
    func startFlow() -> AnyView {
        joinFlowModuleAssembly.make(output: self)
    }
    
    // MARK: - JoinFlowOutput
    
    func onStepChanged(_ step: JoinFlowStep, output: JoinFlowStepOutput) -> AnyView {
        switch step {
        case .code:
            return inviteCodeViewModuleAssembly.make(output: output)
        case .void:
            return voidViewModuleAssembly.make(output: output)
        case .key:
            return keyViewModuleAssembly.make(output: output)
        }
    }
}
