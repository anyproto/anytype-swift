import SwiftUI

protocol SelectRelationListCoordinatorAssemblyProtocol {
    @MainActor
    func make(
        objectId: String,
        style: SelectRelationListStyle,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String]
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
        style: SelectRelationListStyle,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String]
    ) -> AnyView {
        SelectRelationListCoordinatorView(
            model: SelectRelationListCoordinatorViewModel(
                objectId: objectId,
                style: style,
                configuration: configuration,
                selectedOptionsIds: selectedOptionsIds,
                selectRelationListModuleAssembly: self.modulesDI.selectRelationList(),
                relationOptionSettingsModuleAssembly: self.modulesDI.relationOptionSettings()
            )
        ).eraseToAnyView()
    }
}

