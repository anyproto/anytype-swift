import Foundation
import SwiftUI

@MainActor
final class SettingsCoordinatorViewModel: ObservableObject,
                                    SettingsModuleOutput,
                                    SettingsAccountModuleOutput,
                                    AboutModuleOutput {
    
    private let navigationContext: NavigationContextProtocol
    private let appearanceModuleAssembly: SettingsAppearanceModuleAssemblyProtocol
    private let dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol
    private let urlOpener: URLOpenerProtocol
    
    @Injected(\.documentService)
    private var documentService: OpenedDocumentsProviderProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: ApplicationStateServiceProtocol
    
    @Published var showFileStorage = false
    
    init(
        navigationContext: NavigationContextProtocol,
        appearanceModuleAssembly: SettingsAppearanceModuleAssemblyProtocol,
        dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol,
        urlOpener: URLOpenerProtocol
    ) {
        self.navigationContext = navigationContext
        self.appearanceModuleAssembly = appearanceModuleAssembly
        self.dashboardAlertsAssembly = dashboardAlertsAssembly
        self.urlOpener = urlOpener
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
        showFileStorage = true
    }
    
    func onAboutSelected() {
        navigationContext.present(AboutView(output: self))
    }
    
    func onAccountDataSelected() {
        navigationContext.present(SettingsAccountView(output: self))
    }
    
    func onChangeIconSelected(objectId: String) {
        let document = documentService.document(objectId: objectId, forPreview: true)
        let module = ObjectIconPicker(data: ObjectIconPickerData(document: document))
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
    
    // MARK: - AboutModuleOutput
    
    func onLinkOpen(url: URL) {
        urlOpener.openUrl(url, presentationStyle: .pageSheet)
    }
}
