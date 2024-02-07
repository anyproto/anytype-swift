import SwiftUI

protocol ObjectRelationListCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        limitedObjectTypes: [String],
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
        configuration: RelationModuleConfiguration,
        limitedObjectTypes: [String],
        selectedOptionsIds: [String],
        output: ObjectRelationListCoordinatorModuleOutput?
    ) -> AnyView {
        ObjectRelationListCoordinatorView(
            model: ObjectRelationListCoordinatorViewModel(
                objectId: objectId,
                configuration: configuration,
                limitedObjectTypes: limitedObjectTypes,
                selectedOptionsIds: selectedOptionsIds,
                objectRelationListModuleAssembly: self.modulesDI.objectRelationList(),
                output: output
            )
        ).eraseToAnyView()
    }
}

