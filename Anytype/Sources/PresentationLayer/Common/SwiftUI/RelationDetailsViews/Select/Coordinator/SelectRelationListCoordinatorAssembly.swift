import SwiftUI

protocol SelectRelationListCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOption: SelectRelationOption?
    ) -> AnyView
}

final class SelectRelationListCoordinatorAssembly: SelectRelationListCoordinatorAssemblyProtocol {
    
    // MARK: - DI
    
    private let modulesDI: ModulesDIProtocol
    
    init(modulesDI: ModulesDIProtocol) {
        self.modulesDI = modulesDI
    }
    
    // MARK: - JoinFlowCoordinatorAssemblyProtocol
    
    @MainActor
    func make(
        objectId: String,
        configuration: RelationModuleConfiguration,
        selectedOption: SelectRelationOption?
    ) -> AnyView {
        SelectRelationListCoordinatorView(
            model: SelectRelationListCoordinatorViewModel(
                objectId: objectId,
                configuration: configuration,
                selectedOption: selectedOption,
                selectRelationListModuleAssembly: self.modulesDI.selectRelationList(), 
                selectRelationSettingsModuleAssembly: self.modulesDI.selectRelationSettings()
            )
        ).eraseToAnyView()
    }
}

