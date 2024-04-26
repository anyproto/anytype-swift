import Foundation

@MainActor
protocol SettingsCoordinatorProtocol: AnyObject {
    func startFlow()
}

@MainActor
final class SettingsCoordinator: SettingsCoordinatorProtocol, 
                                    SettingsModuleOutput,
                                    SettingsAccountModuleOutput,
                                    AboutModuleOutput,
                                    FileStorageModuleOutput {
    
    private let navigationContext: NavigationContextProtocol
    private let settingsModuleAssembly: SettingsModuleAssemblyProtocol
    private let debugMenuModuleAssembly: DebugMenuModuleAssemblyProtocol
    private let appearanceModuleAssembly: SettingsAppearanceModuleAssemblyProtocol
    private let aboutModuleAssembly: AboutModuleAssemblyProtocol
    private let accountModuleAssembly: SettingsAccountModuleAssemblyProtocol
    private let keychainPhraseModuleAssembly: KeychainPhraseModuleAssemblyProtocol
    private let dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let fileStorageModuleAssembly: FileStorageModuleAssemblyProtocol
    private let documentService: OpenedDocumentsProviderProtocol
    private let urlOpener: URLOpenerProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let serviceLocator: ServiceLocator
    private let applicationStateService: ApplicationStateServiceProtocol
    
    init(
        navigationContext: NavigationContextProtocol,
        settingsModuleAssembly: SettingsModuleAssemblyProtocol,
        debugMenuModuleAssembly: DebugMenuModuleAssemblyProtocol,
        appearanceModuleAssembly: SettingsAppearanceModuleAssemblyProtocol,
        aboutModuleAssembly: AboutModuleAssemblyProtocol,
        accountModuleAssembly: SettingsAccountModuleAssemblyProtocol,
        keychainPhraseModuleAssembly: KeychainPhraseModuleAssemblyProtocol,
        dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        fileStorageModuleAssembly: FileStorageModuleAssemblyProtocol,
        documentService: OpenedDocumentsProviderProtocol,
        urlOpener: URLOpenerProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        serviceLocator: ServiceLocator
    ) {
        self.navigationContext = navigationContext
        self.settingsModuleAssembly = settingsModuleAssembly
        self.debugMenuModuleAssembly = debugMenuModuleAssembly
        self.appearanceModuleAssembly = appearanceModuleAssembly
        self.aboutModuleAssembly = aboutModuleAssembly
        self.accountModuleAssembly = accountModuleAssembly
        self.keychainPhraseModuleAssembly = keychainPhraseModuleAssembly
        self.dashboardAlertsAssembly = dashboardAlertsAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.fileStorageModuleAssembly = fileStorageModuleAssembly
        self.documentService = documentService
        self.urlOpener = urlOpener
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.serviceLocator = serviceLocator
        self.applicationStateService = serviceLocator.applicationStateService()
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
    
    func onAppearanceSelected() {
        let module = appearanceModuleAssembly.make()
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
        let interactor = serviceLocator.objectHeaderInteractor(objectId: objectId)
        let module = objectIconPickerModuleAssembly.make(document: document) { action in
            interactor.handleIconAction(spaceId: document.spaceId, action: action)
        }
        navigationContext.present(module)
    }
    
    // MARK: - SettingsAccountModuleOutput
    
    func onRecoveryPhraseSelected() {
        let module = keychainPhraseModuleAssembly.make(context: .settings)
        navigationContext.present(module)
    }
    
    func onLogoutSelected() {
        let module = dashboardAlertsAssembly.logoutAlert(
            onBackup: { [weak self] in
                guard let self = self else { return }
                self.navigationContext.dismissTopPresented()
                let module = self.keychainPhraseModuleAssembly.make(context: .logout)
                self.navigationContext.present(module)
            },
            onLogout: { [weak self] in
                self?.navigationContext.dismissAllPresented(animated: true, completion: { 
                    self?.applicationStateService.state = .initial
                })
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
    
    // MARK: - AboutModuleOutput
    
    func onLinkOpen(url: URL) {
        urlOpener.openUrl(url, presentationStyle: .pageSheet)
    }
}
