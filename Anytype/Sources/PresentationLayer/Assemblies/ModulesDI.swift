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
        return RelationsListModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func textRelationEditing() -> TextRelationEditingModuleAssemblyProtocol {
        TextRelationEditingModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func undoRedo() -> UndoRedoModuleAssemblyProtocol {
        return UndoRedoModuleAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func objectLayoutPicker() -> ObjectLayoutPickerModuleAssemblyProtocol {
        return ObjectLayoutPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func objectCoverPicker() -> ObjectCoverPickerModuleAssemblyProtocol {
        return ObjectCoverPickerModuleAssembly()
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
    
    func personalization() -> PersonalizationModuleAssemblyProtocol {
        return PersonalizationModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func keychainPhrase() -> KeychainPhraseModuleAssemblyProtocol {
        return KeychainPhraseModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func dashboardAlerts() -> DashboardAlertsAssemblyProtocol {
        return DashboardAlertsAssembly(serviceLocator: serviceLocator, uiHelpersDI: uiHelpersDI)
    }
    
    func authorization() -> AuthModuleAssemblyProtocol {
        return AuthModuleAssembly()
    }
    
    func joinFlow() -> JoinFlowModuleAssemblyProtocol {
        return JoinFlowModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func login() -> LoginViewModuleAssemblyProtocol {
        return LoginViewModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func authKey() -> KeyPhraseViewModuleAssemblyProtocol {
        return KeyPhraseViewModuleAssembly(uiHelpersDI: uiHelpersDI)
    }
    
    func authKeyMoreInfo() -> KeyPhraseMoreInfoViewModuleAssembly {
        return KeyPhraseMoreInfoViewModuleAssembly()
    }
    
    func authSoul() -> SoulViewModuleAssemblyProtocol {
        return SoulViewModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func authCreatingSoul() -> CreatingSoulViewModuleAssemblyProtocol {
        return CreatingSoulViewModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func setObjectCreationSettings() -> SetObjectCreationSettingsModuleAssemblyProtocol {
        return SetObjectCreationSettingsModuleAssembly(serviceLocator: serviceLocator, uiHelperDI: uiHelpersDI)
    }
    
    func setViewSettingsList() -> SetViewSettingsListModuleAssemblyProtocol {
        return SetViewSettingsListModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func setFiltersDateView() -> SetFiltersDateViewModuleAssemblyProtocol {
        SetFiltersDateViewModuleAssembly()
    }
    
    func setFiltersSelectionHeader() -> SetFiltersSelectionHeaderModuleAssemblyProtocol {
        SetFiltersSelectionHeaderModuleAssembly()
    }
    
    func setFiltersListModule() -> SetFiltersListModuleAssemblyProtocol {
        SetFiltersListModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func setViewSettingsImagePreview() -> SetViewSettingsImagePreviewModuleAssemblyProtocol {
        SetViewSettingsImagePreviewModuleAssembly()
    }
    
    func setLayoutSettingsView() -> SetLayoutSettingsViewAssemblyProtocol {
        SetLayoutSettingsViewAssembly(serviceLocator: serviceLocator)
    }
    
    func setViewSettingsGroupByView() -> SetViewSettingsGroupByModuleAssemblyProtocol {
        SetViewSettingsGroupByModuleAssembly()
    }
    
    func setRelationsView() -> SetRelationsViewModuleAssemblyProtocol {
        SetRelationsViewModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func setViewPicker() -> SetViewPickerModuleAssemblyProtocol {
        SetViewPickerModuleAssembly(serviceLocator: serviceLocator)
    }

    func homeBottomNavigationPanel() -> HomeBottomNavigationPanelModuleAssemblyProtocol {
        HomeBottomNavigationPanelModuleAssembly(serviceLocator: serviceLocator)
    }

    func deleteAccount() -> DeleteAccountModuleAssemblyProtocol {
        DeleteAccountModuleAssembly(serviceLocator: serviceLocator)
    }

    func objectTypeSearch() -> ObjectTypeSearchModuleAssemblyProtocol {
        ObjectTypeSearchModuleAssembly(uiHelpersDI: uiHelpersDI, serviceLocator: serviceLocator)
    }
    
    func serverConfiguration() -> ServerConfigurationModuleAssemblyProtocol {
        ServerConfigurationModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func serverDocumentPicker() -> ServerDocumentPickerModuleAssemblyProtocol {
        ServerDocumentPickerModuleAssembly(serviceLocator: serviceLocator)
    }
    
    func sharingTip() -> SharingTipModuleAssemblyProtocol {
        SharingTipModuleAssembly()
    }
    
    func shareOptions() -> ShareOptionsModuleAssemblyProtocol {
        ShareOptionsModuleAssembly(serviceLocator: serviceLocator)
    }
}
