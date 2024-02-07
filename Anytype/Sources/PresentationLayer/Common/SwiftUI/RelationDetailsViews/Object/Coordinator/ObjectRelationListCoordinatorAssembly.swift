import SwiftUI

protocol ObjectRelationListCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        objectId: String,
        mode: ObjectRelationListMode,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: ObjectRelationListCoordinatorModuleOutput?
    ) -> AnyView
}

final class ObjectRelationListCoordinatorAssembly: ObjectRelationListCoordinatorAssemblyProtocol {
    
    // MARK: - DI
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - ObjectRelationListCoordinatorAssemblyProtocol
    
    @MainActor
    func make(
        objectId: String,
        mode: ObjectRelationListMode,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: ObjectRelationListCoordinatorModuleOutput?
    ) -> AnyView {
        ObjectRelationListCoordinatorView(
            model: ObjectRelationListCoordinatorViewModel(
                objectId: objectId,
                mode: mode,
                configuration: configuration,
                selectedOptionsIds: selectedOptionsIds,
                objectRelationListModuleAssembly: self.modulesDI.objectRelationList(),
                output: output
            )
        ).eraseToAnyView()
    }
}

