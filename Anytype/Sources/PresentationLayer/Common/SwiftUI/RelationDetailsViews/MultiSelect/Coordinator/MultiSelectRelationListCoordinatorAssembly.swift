import SwiftUI

protocol MultiSelectRelationListCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOptions: [String]
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
        selectedOptions: [String]
    ) -> AnyView {
        MultiSelectRelationListCoordinatorView(
            model: MultiSelectRelationListCoordinatorViewModel(
                objectId: objectId,
                configuration: configuration,
                selectedOptions: selectedOptions,
                miltiSelectRelationListModuleAssembly: self.modulesDI.multiSelectRelationList(),
                selectRelationSettingsModuleAssembly: self.modulesDI.selectRelationSettings()
            )
        ).eraseToAnyView()
    }
}

