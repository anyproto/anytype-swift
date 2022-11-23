import Foundation

protocol ObjectSettingsCoordinatorAssemblyProtocol {
    func make() -> ObjectSettingsCoordinatorProtocol
}

final class ObjectSettingsCoordinatorAssembly: ObjectSettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - ObjectSettingsCoordinatorAssemblyProtocol
    
    func make() -> ObjectSettingsCoordinatorProtocol {
        return ObjectSettingsCoordinator(
            navigationContext: NavigationContext(
                rootViewController: uiHelpersDI.viewControllerProvider.topViewController
            ),
            objectSettingsModuleAssembly: modulesDI.objectSetting,
            undoRedoModuleAssembly: modulesDI.undoRedo,
            objectLayoutPickerModuleAssembly: modulesDI.objectLayoutPicker,
            objectCoverPickerModuleAssembly: modulesDI.objectCoverPicker,
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker
        )
    }
}
