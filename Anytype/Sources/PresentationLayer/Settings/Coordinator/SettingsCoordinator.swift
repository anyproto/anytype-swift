import Foundation

@MainActor
protocol SettingsCoordinatorProtocol: AnyObject {
    func startFlow()
}

@MainActor
final class SettingsCoordinator: SettingsCoordinatorProtocol, SettingsModuleOutput,
                                    PersonalizationModuleOutput, SettingsAppearanceModuleOutput,
                                    SettingsAccountModuleOutput, AboutModuleOutput, FileStorageModuleOutput {
    
    private let navigationContext: NavigationContextProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let settingsModuleAssembly: SettingsModuleAssemblyProtocol
    private let debugMenuModuleAssembly: DebugMenuModuleAssemblyProtocol
    private let personalizationModuleAssembly: PersonalizationModuleAssemblyProtocol
    private let newSearchModuleAssembly: NewSearchModuleAssemblyProtocol
    private let appearanceModuleAssembly: SettingsAppearanceModuleAssemblyProtocol
    private let wallpaperPickerModuleAssembly: WallpaperPickerModuleAssemblyProtocol
    private let aboutModuleAssembly: AboutModuleAssemblyProtocol
    private let accountModuleAssembly: SettingsAccountModuleAssemblyProtocol
    private let keychainPhraseModuleAssembly: KeychainPhraseModuleAssemblyProtocol
    private let dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let fileStorageModuleAssembly: FileStorageModuleAssemblyProtocol
    private let widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol
    private let documentService: DocumentServiceProtocol
    private let urlOpener: URLOpenerProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    init(
        navigationContext: NavigationContextProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        settingsModuleAssembly: SettingsModuleAssemblyProtocol,
        debugMenuModuleAssembly: DebugMenuModuleAssemblyProtocol,
        personalizationModuleAssembly: PersonalizationModuleAssemblyProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        appearanceModuleAssembly: SettingsAppearanceModuleAssemblyProtocol,
        wallpaperPickerModuleAssembly: WallpaperPickerModuleAssemblyProtocol,
        aboutModuleAssembly: AboutModuleAssemblyProtocol,
        accountModuleAssembly: SettingsAccountModuleAssemblyProtocol,
        keychainPhraseModuleAssembly: KeychainPhraseModuleAssemblyProtocol,
        dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        fileStorageModuleAssembly: FileStorageModuleAssemblyProtocol,
        widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol,
        documentService: DocumentServiceProtocol,
        urlOpener: URLOpenerProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.navigationContext = navigationContext
        self.objectTypeProvider = objectTypeProvider
        self.settingsModuleAssembly = settingsModuleAssembly
        self.debugMenuModuleAssembly = debugMenuModuleAssembly
        self.personalizationModuleAssembly = personalizationModuleAssembly
        self.newSearchModuleAssembly = newSearchModuleAssembly
        self.appearanceModuleAssembly = appearanceModuleAssembly
        self.wallpaperPickerModuleAssembly = wallpaperPickerModuleAssembly
        self.aboutModuleAssembly = aboutModuleAssembly
        self.accountModuleAssembly = accountModuleAssembly
        self.keychainPhraseModuleAssembly = keychainPhraseModuleAssembly
        self.dashboardAlertsAssembly = dashboardAlertsAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.fileStorageModuleAssembly = fileStorageModuleAssembly
        self.widgetObjectListModuleAssembly = widgetObjectListModuleAssembly
        self.documentService = documentService
        self.urlOpener = urlOpener
        self.activeWorkspaceStorage = activeWorkspaceStorage
    }
    
    func startFlow() {
        let module = settingsModuleAssembly.make(output: self)
        navigationContext.present(module)
    }
    
    // MARK: - SettingsModuleOutput
    
    func onDebugMenuSelected() {
        let module = debugMenuModuleAssembly.make()
        navigationContext.present(module)
    }
    
    func onPersonalizationSelected() {
        let module = personalizationModuleAssembly.make(output: self)
        navigationContext.present(module)
    }
    
    func onAppearanceSelected() {
        let module = appearanceModuleAssembly.make(output: self)
        navigationContext.present(module)
    }
    
    func onFileStorageSelected() {
        let module = fileStorageModuleAssembly.make(output: self)
        navigationContext.present(module)
    }
    
    func onAboutSelected() {
        let model = aboutModuleAssembly.make(output: self)
        navigationContext.present(model)
    }
    
    func onAccountDataSelected() {
        let module = accountModuleAssembly.make(output: self)
        navigationContext.present(module)
    }
    
    func onChangeIconSelected(objectId: String) {
        let document = documentService.document(objectId: objectId, forPreview: true)
        let module = objectIconPickerModuleAssembly.make(document: document, objectId: objectId)
        navigationContext.present(module)
    }
    
    // MARK: - PersonalizationModuleOutput
    
    func onDefaultTypeSelected() {
        let module = newSearchModuleAssembly.objectTypeSearchModule(
            title: Loc.chooseDefaultObjectType,
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
            showBookmark: false
        ) { [weak self] type in
            self?.objectTypeProvider.setDefaulObjectType(type: type)
            self?.navigationContext.dismissTopPresented(animated: true)
        }
        navigationContext.present(module)
    }
    
    // MARK: - SettingsAppearanceModuleOutput
    
    func onWallpaperChangeSelected() {
        let module = wallpaperPickerModuleAssembly.make()
        navigationContext.present(module)
    }
    
    // MARK: - SettingsAccountModuleOutput
    
    func onRecoveryPhraseSelected() {
        let module = keychainPhraseModuleAssembly.make(context: .settings)
        navigationContext.present(module)
    }
    
    func onLogoutSelected() {
        let module = dashboardAlertsAssembly.logoutAlert(onBackup: { [weak self] in
            guard let self = self else { return }
            self.navigationContext.dismissTopPresented()
            let module = self.keychainPhraseModuleAssembly.make(context: .logout)
            self.navigationContext.present(module)
        })
        navigationContext.present(module)
    }
    
    func onDeleteAccountSelected() {
        let module = dashboardAlertsAssembly.accountDeletionAlert()
        navigationContext.present(module)
    }
    
    // MARK: - FileStorageModuleOutput
    
    func onClearCacheSelected() {
        let module = dashboardAlertsAssembly.clearCacheAlert()
        navigationContext.present(module)
    }
    
    func onManageFilesSelected() {
        let module = widgetObjectListModuleAssembly.makeFiles()
        navigationContext.present(module)
    }
    
    // MARK: - AboutModuleOutput
    
    func onLinkOpen(url: URL) {
        urlOpener.openUrl(url, presentationStyle: .pageSheet)
    }
}
