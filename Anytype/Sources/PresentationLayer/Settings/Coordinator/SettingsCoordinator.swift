import Foundation
import SwiftUI


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
    private let appearanceModuleAssembly: SettingsAppearanceModuleAssemblyProtocol
    private let keychainPhraseModuleAssembly: KeychainPhraseModuleAssemblyProtocol
    private let dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let documentService: OpenedDocumentsProviderProtocol
    private let urlOpener: URLOpenerProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let serviceLocator: ServiceLocator
    private let applicationStateService: ApplicationStateServiceProtocol
    
    init(
        navigationContext: NavigationContextProtocol,
        appearanceModuleAssembly: SettingsAppearanceModuleAssemblyProtocol,
        keychainPhraseModuleAssembly: KeychainPhraseModuleAssemblyProtocol,
        dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        documentService: OpenedDocumentsProviderProtocol,
        urlOpener: URLOpenerProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        serviceLocator: ServiceLocator
    ) {
        self.navigationContext = navigationContext
        self.appearanceModuleAssembly = appearanceModuleAssembly
        self.keychainPhraseModuleAssembly = keychainPhraseModuleAssembly
        self.dashboardAlertsAssembly = dashboardAlertsAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.documentService = documentService
        self.urlOpener = urlOpener
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.serviceLocator = serviceLocator
        self.applicationStateService = serviceLocator.applicationStateService()
    }
    
    func startFlow() {
        navigationContext.present(SettingsView(output: self))
    }
    
    // MARK: - SettingsModuleOutput
    
    func onDebugMenuSelected() {
        navigationContext.present(DebugMenuView())
    }
    
    func onAppearanceSelected() {
        let module = appearanceModuleAssembly.make()
        navigationContext.present(module)
    }
    
    func onFileStorageSelected() {
        navigationContext.present(FileStorageView(output: self))
    }
    
    func onAboutSelected() {
        navigationContext.present(AboutView(output: self))
    }
    
    func onAccountDataSelected() {
        navigationContext.present(SettingsAccountView(output: self))
    }
    
    func onChangeIconSelected(objectId: String) {
        let document = documentService.document(objectId: objectId, forPreview: true)
        let interactor = serviceLocator.objectHeaderInteractor()
        let module = objectIconPickerModuleAssembly.make(document: document) { action in
            interactor.handleIconAction(objectId: objectId, spaceId: document.spaceId, action: action)
        }
        navigationContext.present(module)
    }
    
    func onSpacesSelected() {
        navigationContext.present(SpacesManagerView())
    }
    
    func onMembershipSelected() {
        navigationContext.present(MembershipCoordinator())
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
