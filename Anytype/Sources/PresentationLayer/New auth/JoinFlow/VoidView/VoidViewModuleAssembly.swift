import SwiftUI

protocol VoidViewModuleAssemblyProtocol {
    @MainActor
    func make(output: JoinFlowStepOutput?) -> AnyView
}

final class VoidViewModuleAssembly: VoidViewModuleAssemblyProtocol {
    
    // MARK: - VoidViewModuleAssemblyProtocol
    
    @MainActor
    func make(output: JoinFlowStepOutput?) -> AnyView {
        return VoidView(
            model: VoidViewModel(output: output)
        ).eraseToAnyView()
    }
}
