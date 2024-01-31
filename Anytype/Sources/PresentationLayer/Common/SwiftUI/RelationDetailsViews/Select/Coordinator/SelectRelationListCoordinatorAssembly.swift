import SwiftUI

protocol SelectRelationListCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOptionId: String?
    ) -> AnyView
}

final class SelectRelationListCoordinatorAssembly: SelectRelationListCoordinatorAssemblyProtocol {
    
    // MARK: - DI
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - SelectRelationListCoordinatorAssemblyProtocol
    
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOptionId: String?
    ) -> AnyView {
        SelectRelationListCoordinatorView(
            model: SelectRelationListCoordinatorViewModel(
                objectId: objectId,
                configuration: configuration,
                selectedOptionId: selectedOptionId,
                selectRelationListModuleAssembly: self.modulesDI.selectRelationList(),
                relationOptionSettingsModuleAssembly: self.modulesDI.relationOptionSettings()
            )
        ).eraseToAnyView()
    }
}

