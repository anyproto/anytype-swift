import SwiftUI

protocol InviteCodeViewModuleAssemblyProtocol {
    @MainActor
    func make(output: JoinFlowStepOutput?) -> AnyView
}

final class InviteCodeViewModuleAssembly: InviteCodeViewModuleAssemblyProtocol {
    
    // MARK: - InviteCodeViewModuleAssemblyProtocol
    
    @MainActor
    func make(output: JoinFlowStepOutput?) -> AnyView {
        return InviteCodeView(
            model: InviteCodeViewModel(output: output)
        ).eraseToAnyView()
    }
}
