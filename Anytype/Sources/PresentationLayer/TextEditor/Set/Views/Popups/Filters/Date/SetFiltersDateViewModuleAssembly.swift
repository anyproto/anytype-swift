import SwiftUI

protocol SetFiltersDateViewModuleAssemblyProtocol {
    @MainActor
    func make(
        filter: SetFilter,
        selectionModel: SetFiltersSelectionViewModel?,
        onApplyDate: @escaping (SetFiltersDate) -> Void
    ) -> AnyView
}

final class SetFiltersDateViewModuleAssembly: SetFiltersDateViewModuleAssemblyProtocol {
    
    // MARK: - SetFiltersDateViewModuleAssemblyProtocol
    
    @MainActor
    func make(
        filter: SetFilter,
        selectionModel: SetFiltersSelectionViewModel?,
        onApplyDate: @escaping (SetFiltersDate) -> Void
    ) -> AnyView {
        return SetFiltersDateView(
            viewModel: SetFiltersDateViewModel(
                filter: filter,
                setSelectionModel: selectionModel,
                onApplyDate: onApplyDate
            )
        ).eraseToAnyView()
    }
}
