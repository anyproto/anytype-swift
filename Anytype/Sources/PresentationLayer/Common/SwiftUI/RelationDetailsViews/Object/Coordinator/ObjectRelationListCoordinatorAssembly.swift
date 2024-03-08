import SwiftUI

protocol ObjectRelationListCoordinatorAssemblyProtocol {
    @MainActor
    func make(
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
        mode: ObjectRelationListMode,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String],
        output: ObjectRelationListCoordinatorModuleOutput?
    ) -> AnyView {
        ObjectRelationListCoordinatorView(
            model: ObjectRelationListCoordinatorViewModel(
                mode: mode,
                configuration: configuration,
                selectedOptionsIds: selectedOptionsIds,
                output: output
            )
        ).eraseToAnyView()
    }
}

