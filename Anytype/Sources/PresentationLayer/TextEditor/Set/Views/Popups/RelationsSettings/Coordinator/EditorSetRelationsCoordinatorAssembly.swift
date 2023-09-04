import SwiftUI
import Services

protocol EditorSetRelationsCoordinatorAssemblyProtocol {
    @MainActor
    func make(with setDocument: SetDocumentProtocol) -> AnyView
}

final class EditorSetRelationsCoordinatorAssembly: EditorSetRelationsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(modulesDI: ModulesDIProtocol, coordinatorsDI: CoordinatorsDIProtocol) {
        self.modulesDI = modulesDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - SetFiltersListCoordinatorAssemblyProtocol
    
    @MainActor
    func make(with setDocument: SetDocumentProtocol) -> AnyView {
        return EditorSetRelationsCoordinatorView(
            model: EditorSetRelationsCoordinatorViewModel(
                setDocument: setDocument,
                setRelationsViewModuleAssembly: self.modulesDI.setRelationsView(),
                addNewRelationCoordinator: self.coordinatorsDI.addNewRelation().make()
            )
        ).eraseToAnyView()
    }
}
