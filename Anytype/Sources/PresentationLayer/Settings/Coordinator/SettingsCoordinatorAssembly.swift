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
            objectTypeProvider: serviceLocator.objectTypeProvider(),
            settingsModuleAssembly: modulesDI.settings(),
            debugMenuModuleAssembly: modulesDI.debugMenu(),
            personalizationModuleAssembly: modulesDI.personalization(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            appearanceModuleAssembly: modulesDI.settingsAppearance(),
            wallpaperPickerModuleAssembly: modulesDI.wallpaperPicker(),
            aboutModuleAssembly: modulesDI.about(),
            accountModuleAssembly: modulesDI.settingsAccount(),
            keychainPhraseModuleAssembly: modulesDI.keychainPhrase(),
            dashboardAlertsAssembly: modulesDI.dashboardAlerts(),
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker(),
            fileStorageModuleAssembly: modulesDI.fileStorage(),
            widgetObjectListModuleAssembly: modulesDI.widgetObjectList(),
            documentService: serviceLocator.documentService(),
            urlOpener: uiHelpersDI.urlOpener()
        )
    }
}
