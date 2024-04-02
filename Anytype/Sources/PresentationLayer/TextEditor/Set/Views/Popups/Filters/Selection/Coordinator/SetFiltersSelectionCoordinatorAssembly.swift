import SwiftUI
import Services

protocol SetFiltersSelectionCoordinatorAssemblyProtocol {
    @MainActor
    func make(with spaceId: String, filter: SetFilter, completion: @escaping (SetFilter) -> Void) -> AnyView
}

final class SetFiltersSelectionCoordinatorAssembly: SetFiltersSelectionCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsDI: CoordinatorsDI
    
    init(modulesDI: ModulesDIProtocol, coordinatorsDI: CoordinatorsDI) {
        self.modulesDI = modulesDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetFiltersSelectionCoordinatorAssemblyProtocol
    
    @MainActor
    func make(with spaceId: String, filter: SetFilter, completion: @escaping (SetFilter) -> Void) -> AnyView {
        return SetFiltersSelectionCoordinatorView(
            model: SetFiltersSelectionCoordinatorViewModel(
                spaceId: spaceId,
                filter: filter,
                newSearchModuleAssembly: self.modulesDI.newSearch(),
                completion: completion
            )
        ).eraseToAnyView()
    }
}
