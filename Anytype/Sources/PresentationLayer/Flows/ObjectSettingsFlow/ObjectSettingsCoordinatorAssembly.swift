import Foundation

protocol ObjectSettingsCoordinatorAssemblyProtocol {
    func make(document: BaseDocumentProtocol, browserController: EditorBrowserController?) -> ObjectSettingsCoordinatorProtocol
}

final class ObjectSettingsCoordinatorAssembly: ObjectSettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol,
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
        self.coordinatorsDI = coordinatorsDI
    }
    
    // MARK: - ObjectSettingsCoordinatorAssemblyProtocol
    
    func make(document: BaseDocumentProtocol, browserController: EditorBrowserController?) -> ObjectSettingsCoordinatorProtocol {
        return ObjectSettingsCoordinator(
            document: document,
            navigationContext: uiHelpersDI.commonNavigationContext,
            objectSettingsModuleAssembly: modulesDI.objectSetting,
            undoRedoModuleAssembly: modulesDI.undoRedo,
            objectLayoutPickerModuleAssembly: modulesDI.objectLayoutPicker,
            objectCoverPickerModuleAssembly: modulesDI.objectCoverPicker,
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker,
            relationsListModuleAssembly: modulesDI.relationsList,
            relationValueCoordinator: coordinatorsDI.relationValue.make(),
            editorPageCoordinator: coordinatorsDI.editorPage.make(browserController: browserController),
            addNewRelationCoordinator: coordinatorsDI.addNewRelation.make(document: document),
            searchModuleAssembly: modulesDI.search,
            newSearchModuleAssembly: modulesDI.newSearch
        )
    }
}
