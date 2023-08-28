import SwiftUI
import Services

protocol SetFiltersSelectionViewModuleAssemblyProtocol {
    @MainActor
    func make(
        with filter: SetFilter,
        output: SetFiltersSelectionCoordinatorOutput?,
        contentViewBuilder: SetFiltersContentViewBuilder,
        completion: @escaping (SetFilter) -> Void
    ) -> AnyView
}

final class SetFiltersSelectionViewModuleAssembly: SetFiltersSelectionViewModuleAssemblyProtocol {
    
    // MARK: - SetFiltersSelectionViewModuleAssemblyProtocol
    
    @MainActor
    func make(
        with filter: SetFilter,
        output: SetFiltersSelectionCoordinatorOutput?,
        contentViewBuilder: SetFiltersContentViewBuilder,
        completion: @escaping (SetFilter) -> Void
    ) -> AnyView {
        return SetFiltersSelectionView(
            viewModel: SetFiltersSelectionViewModel(
                filter: filter,
                output: output,
                contentViewBuilder: contentViewBuilder,
                onApply: completion
            )
        ).eraseToAnyView()
    }
    
}
