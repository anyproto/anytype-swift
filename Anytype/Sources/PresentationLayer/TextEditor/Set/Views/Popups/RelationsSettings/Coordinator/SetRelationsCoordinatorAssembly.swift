import SwiftUI
import Services

protocol SetRelationsCoordinatorAssemblyProtocol {
    @MainActor
    func make(with setDocument: SetDocumentProtocol) -> AnyView
}

final class SetRelationsCoordinatorAssembly: SetRelationsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(modulesDI: ModulesDIProtocol, coordinatorsDI: CoordinatorsDIProtocol) {
        self.modulesDI = modulesDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetFiltersListCoordinatorAssemblyProtocol
    
    @MainActor
    func make(with setDocument: SetDocumentProtocol) -> AnyView {
        return SetRelationsCoordinatorView(
            model: SetRelationsCoordinatorViewModel(
                setDocument: setDocument,
                setRelationsViewModuleAssembly: self.modulesDI.setRelationsView(),
                addNewRelationCoordinator: self.coordinatorsDI.addNewRelation().make()
            )
        ).eraseToAnyView()
    }
}
