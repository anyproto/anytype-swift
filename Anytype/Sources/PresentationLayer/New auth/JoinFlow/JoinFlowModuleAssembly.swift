import SwiftUI

protocol JoinFlowModuleAssemblyProtocol {
    @MainActor
    func make(output: JoinFlowOutput?) -> AnyView
}

final class JoinFlowModuleAssembly: JoinFlowModuleAssemblyProtocol {
    
    // MARK: - JoinModuleAssemblyProtocol
    
    @MainActor
    func make(output: JoinFlowOutput?) -> AnyView {
        return JoinFlowView(
            model: JoinFlowViewModel(output: output)
        )
        .eraseToAnyView()
    }
}
