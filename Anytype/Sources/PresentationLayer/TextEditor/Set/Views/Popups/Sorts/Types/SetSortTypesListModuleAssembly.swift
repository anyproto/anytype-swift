import SwiftUI

protocol SetSortTypesListModuleAssemblyProtocol {
    @MainActor
    func make(with setSort: SetSort, completion: @escaping (SetSort) -> Void) -> AnyView
}

final class SetSortTypesListModuleAssembly: SetSortTypesListModuleAssemblyProtocol {
    
    // MARK: - SetSortTypesListModuleAssemblyProtocol
    
    @MainActor
    func make(with setSort: SetSort, completion: @escaping (SetSort) -> Void) -> AnyView {
        return CheckPopupView(
            viewModel: SetSortTypesListViewModel(
                sort: setSort,
                completion: completion
            )
        )
        .eraseToAnyView()
    }
}
