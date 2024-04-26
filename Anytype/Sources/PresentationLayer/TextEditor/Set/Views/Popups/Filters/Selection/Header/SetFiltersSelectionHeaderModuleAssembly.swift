import SwiftUI
import Services

protocol SetFiltersSelectionHeaderModuleAssemblyProtocol {
    @MainActor
    func make(
        filter: SetFilter,
        output: SetFiltersSelectionCoordinatorOutput?,
        onConditionChanged: @escaping (DataviewFilter.Condition) -> Void
    ) -> AnyView
}

final class SetFiltersSelectionHeaderModuleAssembly: SetFiltersSelectionHeaderModuleAssemblyProtocol {
    
    // MARK: - SetFiltersSelectionHeaderModuleAssemblyProtocol
    
    @MainActor
    func make(
        filter: SetFilter,
        output: SetFiltersSelectionCoordinatorOutput?,
        onConditionChanged: @escaping (DataviewFilter.Condition) -> Void
    ) -> AnyView {
        return SetFiltersSelectionHeaderView(
            viewModel: SetFiltersSelectionHeaderViewModel(
                filter: filter,
                output: output,
                onConditionChanged: onConditionChanged
            )
        ).eraseToAnyView()
    }
}
