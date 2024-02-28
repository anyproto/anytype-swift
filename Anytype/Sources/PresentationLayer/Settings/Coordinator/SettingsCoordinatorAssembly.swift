import Foundation

protocol SettingsCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> SettingsCoordinatorProtocol
}

final class SettingsCoordinatorAssembly: SettingsCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol,
        serviceLocator: ServiceLocator
    ) {
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - SettingsCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> SettingsCoordinatorProtocol {
        return SettingsCoordinator(
            navigationContext: uiHelpersDI.commonNavigationContext(),
            settingsModuleAssembly: modulesDI.settings(),
            debugMenuModuleAssembly: modulesDI.debugMenu(),
            appearanceModuleAssembly: modulesDI.settingsAppearance(),
            aboutModuleAssembly: modulesDI.about(),
            accountModuleAssembly: modulesDI.settingsAccount(),
            keychainPhraseModuleAssembly: modulesDI.keychainPhrase(),
            dashboardAlertsAssembly: modulesDI.dashboardAlerts(),
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker(),
            fileStorageModuleAssembly: modulesDI.fileStorage(),
            documentService: serviceLocator.documentService(),
            urlOpener: uiHelpersDI.urlOpener(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            serviceLocator: serviceLocator,
            spacesManagerModuleAssembly: modulesDI.spacesManager(),
            membershipModuleAssembly: modulesDI.membership()
        )
    }
}
