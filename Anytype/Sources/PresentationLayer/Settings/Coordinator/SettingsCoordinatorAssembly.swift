import Foundation

protocol SettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> SettingsCoordinatorProtocol
}

final class SettingsCoordinatorAssembly: SettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol,
        coordinatorsDI: CoordinatorsDIProtocol,
        serviceLocator: ServiceLocator
    ) {
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
        self.coordinatorsDI = coordinatorsDI
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SettingsCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> SettingsCoordinatorProtocol {
        return SettingsCoordinator(
            navigationContext: uiHelpersDI.commonNavigationContext(),
            settingsModuleAssembly: modulesDI.settings(),
            appearanceModuleAssembly: modulesDI.settingsAppearance(),
            keychainPhraseModuleAssembly: modulesDI.keychainPhrase(),
            dashboardAlertsAssembly: modulesDI.dashboardAlerts(),
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker(),
            documentService: serviceLocator.documentService(),
            urlOpener: uiHelpersDI.urlOpener(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            serviceLocator: serviceLocator,
            spacesManagerModuleAssembly: modulesDI.spacesManager()
        )
    }
}
