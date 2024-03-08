import SwiftUI

protocol SelectRelationListCoordinatorAssemblyProtocol {
    @MainActor
    func make(
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
        style: SelectRelationListStyle,
        configuration: RelationModuleConfiguration,
        selectedOptionsIds: [String]
    ) -> AnyView {
        SelectRelationListCoordinatorView(
            model: SelectRelationListCoordinatorViewModel(
                style: style,
                configuration: configuration,
                selectedOptionsIds: selectedOptionsIds,
                selectRelationListModuleAssembly: self.modulesDI.selectRelationList()
            )
        ).eraseToAnyView()
    }
}

