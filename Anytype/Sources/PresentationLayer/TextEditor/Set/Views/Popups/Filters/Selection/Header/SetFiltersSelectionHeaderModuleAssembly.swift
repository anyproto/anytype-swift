import SwiftUI
import Services

protocol SetFiltersSelectionHeaderModuleAssemblyProtocol {
    @MainActor
    func make(filter: SetFilter, output: SetFiltersSelectionCoordinatorOutput?) -> AnyView
}

final class SetFiltersSelectionHeaderModuleAssembly: SetFiltersSelectionHeaderModuleAssemblyProtocol {
    
    // MARK: - SetFiltersSelectionHeaderModuleAssemblyProtocol
    
    @MainActor
    func make(filter: SetFilter,output: SetFiltersSelectionCoordinatorOutput?) -> AnyView {
        return SetFiltersSelectionHeaderView(
            viewModel: SetFiltersSelectionHeaderViewModel(
                filter: filter,
                output: output
            )
        ).eraseToAnyView()
    }
}
