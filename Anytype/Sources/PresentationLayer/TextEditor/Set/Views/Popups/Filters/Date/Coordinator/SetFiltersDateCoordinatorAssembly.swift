import SwiftUI

protocol SetFiltersDateCoordinatorAssemblyProtocol {
    @MainActor
    func make(filter: SetFilter) -> AnyView
}

final class SetFiltersDateCoordinatorAssembly: SetFiltersDateCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - SetFiltersDateCoordinatorAssemblyProtocol
    
    @MainActor
    func make(filter: SetFilter) -> AnyView {
        return SetFiltersDateCoordinatorView(
            model: SetFiltersDateCoordinatorViewModel(
                filter: filter,
                setFiltersDateViewModuleAssembly: self.modulesDI.setFiltersDateView(),
                setTextViewModuleAssembly: self.modulesDI.setTextView()
            )
        ).eraseToAnyView()
    }
}
