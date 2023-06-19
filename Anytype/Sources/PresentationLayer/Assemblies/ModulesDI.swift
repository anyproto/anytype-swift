import Foundation

final class ModulesDI: ModulesDIProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    private let widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol, widgetsSubmoduleDI: WidgetsSubmoduleDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
        self.widgetsSubmoduleDI = widgetsSubmoduleDI
    }
    
    // MARK: - ModulesDIProtocol
    
    func relationValue() -> RelationValueModuleAssemblyProtocol {
        return RelationValueModuleAssembly(modulesDI: self, serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func relationsList() -> RelationsListModuleAssemblyProtocol {
        return RelationsListModuleAssembly()
    }
    
    func undoRedo() -> UndoRedoModuleAssemblyProtocol {
        return UndoRedoModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func objectLayoutPicker() -> ObjectLayoutPickerModuleAssemblyProtocol {
        return ObjectLayoutPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func objectCoverPicker() -> ObjectCoverPickerModuleAssemblyProtocol {
        return ObjectCoverPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func objectIconPicker() -> ObjectIconPickerModuleAssemblyProtocol {
        return ObjectIconPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func objectSetting() -> ObjectSettingModuleAssemblyProtocol {
        return ObjectSettingModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func search() -> SearchModuleAssemblyProtocol {
        return SearchModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func createObject() -> CreateObjectModuleAssemblyProtocol {
        return CreateObjectModuleAssembly(serviceLocator: serviceLocator)
    }

    func codeLanguageList() -> CodeLanguageListModuleAssemblyProtocol {
        return CodeLanguageListModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func newSearch() -> NewSearchModuleAssemblyProtocol {
        return NewSearchModuleAssembly(uiHelpersDI: uiHelpersDI, serviceLocator: serviceLocator)
    }
    
    func newRelation() -> NewRelationModuleAssemblyProtocol {
        return NewRelationModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func homeWidgets() -> HomeWidgetsModuleAssemblyProtocol {
        return HomeWidgetsModuleAssembly(
            serviceLocator: serviceLocator,
            uiHelpersDI: uiHelpersDI,
            widgetsSubmoduleDI:  widgetsSubmoduleDI
        )
    }
    
    func textIconPicker() -> TextIconPickerModuleAssemblyProtocol {
        return TextIconPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func widgetType() -> WidgetTypeModuleAssemblyProtocol {
        return WidgetTypeModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func widgetObjectList() -> WidgetObjectListModuleAssemblyProtocol {
        return WidgetObjectListModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func settingsAppearance() -> SettingsAppearanceModuleAssemblyProtocol {
        return SettingsAppearanceModuleAssembly(uiHelpersDI: uiHelpersDI)
    }
    
    func wallpaperPicker() -> WallpaperPickerModuleAssemblyProtocol {
        return WallpaperPickerModuleAssembly()
    }
    
    func about() -> AboutModuleAssemblyProtocol {
        return AboutModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func personalization() -> PersonalizationModuleAssemblyProtocol {
        return PersonalizationModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func keychainPhrase() -> KeychainPhraseModuleAssemblyProtocol {
        return KeychainPhraseModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func dashboardAlerts() -> DashboardAlertsAssemblyProtocol {
        return DashboardAlertsAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func settings() -> SettingsModuleAssemblyProtocol {
        return SettingsModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func debugMenu() -> DebugMenuModuleAssemblyProtocol {
        return DebugMenuModuleAssembly()
    }
    
    func settingsAccount() -> SettingsAccountModuleAssemblyProtocol {
        return SettingsAccountModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func fileStorage() -> FileStorageModuleAssemblyProtocol {
        return FileStorageModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func authorization() -> AuthModuleAssemblyProtocol {
        return AuthModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func joinFlow() -> JoinFlowModuleAssemblyProtocol {
        return JoinFlowModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func login() -> LoginViewModuleAssemblyProtocol {
        return LoginViewModuleAssembly()
    }
    
    // @joe_pusya: will be moved to separate modulesDI
    
    func authVoid() -> VoidViewModuleAssemblyProtocol {
        return VoidViewModuleAssembly()
    }
    
    func authKey() -> KeyPhraseViewModuleAssemblyProtocol {
        return KeyPhraseViewModuleAssembly(uiHelpersDI: uiHelpersDI, serviceLocator: serviceLocator)
    }
    
    func authSoul() -> SoulViewModuleAssemblyProtocol {
        return SoulViewModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func authCreatingSoul() -> CreatingSoulViewModuleAssemblyProtocol {
        return CreatingSoulViewModuleAssembly(serviceLocator: serviceLocator)
    }
}
