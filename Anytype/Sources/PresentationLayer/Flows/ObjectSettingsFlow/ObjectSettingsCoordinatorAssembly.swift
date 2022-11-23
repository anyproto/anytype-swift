import Foundation

protocol ObjectSettingsCoordinatorAssemblyProtocol {
    func make() -> ObjectSettingsCoordinatorProtocol
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
    
    func make(document: BaseDocumentProtocol) -> ObjectSettingsCoordinatorProtocol {
        return ObjectSettingsCoordinator(
            document: document,
            navigationContext: NavigationContext(
                rootViewController: uiHelpersDI.viewControllerProvider.topViewController
            ),
            objectSettingsModuleAssembly: modulesDI.objectSetting,
            undoRedoModuleAssembly: modulesDI.undoRedo,
            objectLayoutPickerModuleAssembly: modulesDI.objectLayoutPicker,
            objectCoverPickerModuleAssembly: modulesDI.objectCoverPicker,
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker,
            relationsListModuleAssembly: modulesDI.relationsList,
            relationValueCoordinator: coordinatorsDI.relationValue.make()
            editorPageCoordinator: coordinatorsDI.editorPage.make(rootController: <#T##EditorBrowserController?#>, viewController: <#T##UIViewController?#>),
            addNewRelationCoordinator: coordinatorsDI.addNewRelation.make(document: document)
        )
    }
}
