import Foundation

protocol AddNewRelationCoordinatorAssemblyProtocol {
    func make(document: BaseDocumentProtocol) -> AddNewRelationCoordinatorProtocol
}

final class AddNewRelationCoordinatorAssembly: AddNewRelationCoordinatorAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    private let modulesDI: ModulesDIProtocol
    
    init(uiHelpersDI: UIHelpersDIProtocol, modulesDI: ModulesDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
        self.modulesDI = modulesDI
    }
    
    func make(document: BaseDocumentProtocol) -> AddNewRelationCoordinatorProtocol {
        return AddNewRelationCoordinator(
            document: document,
            navigationContext: uiHelpersDI.commonNavigationContext(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            newRelationModuleAssembly: modulesDI.newRelation()
        )
    }
}
