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
    private let dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol
    private let objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol
    private let urlOpener: URLOpenerProtocol
    private let serviceLocator: ServiceLocator
    
    @Injected(\.documentService)
    private var documentService: OpenedDocumentsProviderProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: ApplicationStateServiceProtocol
    
    init(
        navigationContext: NavigationContextProtocol,
        appearanceModuleAssembly: SettingsAppearanceModuleAssemblyProtocol,
        dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol,
        objectIconPickerModuleAssembly: ObjectIconPickerModuleAssemblyProtocol,
        urlOpener: URLOpenerProtocol,
        serviceLocator: ServiceLocator
    ) {
        self.navigationContext = navigationContext
        self.appearanceModuleAssembly = appearanceModuleAssembly
        self.dashboardAlertsAssembly = dashboardAlertsAssembly
        self.objectIconPickerModuleAssembly = objectIconPickerModuleAssembly
        self.urlOpener = urlOpener
        self.serviceLocator = serviceLocator
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
        navigationContext.present(KeychainPhraseView(context: .settings))
    }
    
    func onLogoutSelected() {
        let module = dashboardAlertsAssembly.logoutAlert(
            onBackup: { [weak self] in
                guard let self = self else { return }
                self.navigationContext.dismissTopPresented()
                self.navigationContext.present(KeychainPhraseView(context: .logout))
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
