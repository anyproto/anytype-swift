import SwiftUI

protocol CreatingSoulViewModuleAssemblyProtocol {
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView
}

final class CreatingSoulViewModuleAssembly: CreatingSoulViewModuleAssemblyProtocol {
    
    // MARK: - CreatingSoulViewModuleAssemblyProtocol
    
    @MainActor
    func make(state: JoinFlowState, output: JoinFlowStepOutput?) -> AnyView {
        return CreatingSoulView(
            model: CreatingSoulViewModel(state: state, output: output)
        ).eraseToAnyView()
    }
}
