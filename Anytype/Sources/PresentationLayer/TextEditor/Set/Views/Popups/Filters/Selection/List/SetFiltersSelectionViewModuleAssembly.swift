import SwiftUI
import Services

protocol SetFiltersSelectionViewModuleAssemblyProtocol {
    @MainActor
    func make(
        with filter: SetFilter,
        contentViewBuilder: SetFiltersContentViewBuilder,
        completion: @escaping (SetFilter) -> Void
    ) -> AnyView
}

final class SetFiltersSelectionViewModuleAssembly: SetFiltersSelectionViewModuleAssemblyProtocol {
    
    // MARK: - SetFiltersSelectionViewModuleAssemblyProtocol
    
    @MainActor
    func make(
        with filter: SetFilter,
        contentViewBuilder: SetFiltersContentViewBuilder,
        completion: @escaping (SetFilter) -> Void
    ) -> AnyView {
        return SetFiltersSelectionView(
            viewModel: SetFiltersSelectionViewModel(
                filter: filter,
                contentViewBuilder: contentViewBuilder,
                onApply: completion
            )
        ).eraseToAnyView()
    }
    
    
}
