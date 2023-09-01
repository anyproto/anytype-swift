import SwiftUI
import Services

protocol SetFiltersListCoordinatorAssemblyProtocol {
    @MainActor
    func make(with setDocument: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) -> AnyView
}

final class SetFiltersListCoordinatorAssembly: SetFiltersListCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(modulesDI: ModulesDIProtocol, coordinatorsDI: CoordinatorsDIProtocol) {
        self.modulesDI = modulesDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetFiltersListCoordinatorAssemblyProtocol
    
    @MainActor
    func make(with setDocument: SetDocumentProtocol, subscriptionDetailsStorage: ObjectDetailsStorage) -> AnyView {
        return SetFiltersListCoordinatorView(
            model: SetFiltersListCoordinatorViewModel(
                setDocument: setDocument,
                subscriptionDetailsStorage: subscriptionDetailsStorage,
                setFiltersListModuleAssembly: self.modulesDI.setFiltersListModule(),
                setFiltersSelectionCoordinatorAssembly: self.coordinatorsDI.setFiltersSelection(),
                newSearchModuleAssembly: self.modulesDI.newSearch()
            )
        ).eraseToAnyView()
    }
}
