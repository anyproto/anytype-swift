import SwiftUI

protocol MultiSelectRelationListCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String]
    ) -> AnyView
}

final class MultiSelectRelationListCoordinatorAssembly: MultiSelectRelationListCoordinatorAssemblyProtocol {
    
    // MARK: - DI
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - MultiSelectRelationListCoordinatorAssemblyProtocol
    
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String]
    ) -> AnyView {
        MultiSelectRelationListCoordinatorView(
            model: MultiSelectRelationListCoordinatorViewModel(
                objectId: objectId,
                configuration: configuration,
                selectedOptionsIds: selectedOptionsIds,
                miltiSelectRelationListModuleAssembly: self.modulesDI.multiSelectRelationList(),
                relationOptionSettingsModuleAssembly: self.modulesDI.relationOptionSettings()
            )
        ).eraseToAnyView()
    }
}

