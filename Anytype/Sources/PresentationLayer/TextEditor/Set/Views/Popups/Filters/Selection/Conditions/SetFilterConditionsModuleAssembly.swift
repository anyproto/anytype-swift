import SwiftUI
import Services

protocol SetFilterConditionsModuleAssemblyProtocol {
    @MainActor
    func make(with filter: SetFilter, completion: @escaping (DataviewFilter.Condition) -> Void) -> AnyView
}

final class SetFilterConditionsModuleAssembly: SetFilterConditionsModuleAssemblyProtocol {
    
    // MARK: - SetFilterConditionsModuleAssemblyProtocol
    
    @MainActor
    func make(with filter: SetFilter, completion: @escaping (DataviewFilter.Condition) -> Void) -> AnyView {
        return CheckPopupView(
            viewModel: SetFilterConditionsViewModel(
                filter: filter,
                onSelect: completion
            )
        )
        .eraseToAnyView()
    }
}
