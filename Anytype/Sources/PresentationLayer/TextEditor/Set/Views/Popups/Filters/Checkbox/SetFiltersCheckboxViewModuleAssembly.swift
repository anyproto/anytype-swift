import SwiftUI

protocol SetFiltersCheckboxViewModuleAssemblyProtocol {
    @MainActor
    func make(with filter: SetFilter, onApplyCheckbox: @escaping (Bool) -> Void) -> AnyView
}

final class SetFiltersCheckboxViewModuleAssembly: SetFiltersCheckboxViewModuleAssemblyProtocol {
    
    // MARK: - SetFiltersTextViewModuleAssemblyProtocol
    
    @MainActor
    func make(with filter: SetFilter, onApplyCheckbox: @escaping (Bool) -> Void) -> AnyView {
        return SetFiltersCheckboxView(
            viewModel: SetFiltersCheckboxViewModel(
                filter: filter,
                onApplyCheckbox: onApplyCheckbox
            )
        ).eraseToAnyView()
    }
}
