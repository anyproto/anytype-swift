import SwiftUI

protocol SetFiltersTextViewModuleAssemblyProtocol {
    @MainActor
    func make(with filter: SetFilter, onApplyText: @escaping (String) -> Void) -> AnyView
}

final class SetFiltersTextViewModuleAssembly: SetFiltersTextViewModuleAssemblyProtocol {
    
    // MARK: - SetFiltersTextViewModuleAssemblyProtocol
    
    @MainActor
    func make(with filter: SetFilter, onApplyText: @escaping (String) -> Void) -> AnyView {
        return SetFiltersTextView(
            viewModel: SetFiltersTextViewModel(
                filter: filter,
                onApplyText: onApplyText
            )
        ).eraseToAnyView()
    }
}
