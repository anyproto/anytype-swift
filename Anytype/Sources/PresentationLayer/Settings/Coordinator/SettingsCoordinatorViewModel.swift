import Foundation
import SwiftUI

@MainActor
final class SettingsCoordinatorViewModel: ObservableObject,
                                    SettingsModuleOutput,
                                    SettingsAccountModuleOutput,
                                    AboutModuleOutput {
    
    private let navigationContext: NavigationContextProtocol
    private let dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol
    private let urlOpener: URLOpenerProtocol
    
    @Injected(\.documentService)
    private var documentService: OpenedDocumentsProviderProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: ApplicationStateServiceProtocol
    
    @Published var showFileStorage = false
    @Published var showAppearance = false
    @Published var showLogoutAlert = false
    @Published var showSettingsAccount = false
    @Published var showKeychainPhrase = false
    @Published var dismissAllPresented = false
    
    init(
        navigationContext: NavigationContextProtocol,
        dashboardAlertsAssembly: DashboardAlertsAssemblyProtocol,
        urlOpener: URLOpenerProtocol
    ) {
        self.navigationContext = navigationContext
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
        showAppearance = true
    }
    
    func onFileStorageSelected() {
        showFileStorage = true
    }
    
    func onAboutSelected() {
        navigationContext.present(AboutView(output: self))
    }
    
    func onAccountDataSelected() {
        showSettingsAccount = true
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
    
    func onBackupTap() {
        showKeychainPhrase = true
    }
    
    func onLogoutConfirmTap() {
        applicationStateService.state = .initial
    }
    
    // MARK: - SettingsAccountModuleOutput
    
    func onRecoveryPhraseSelected() {
        navigationContext.present(KeychainPhraseView(context: .settings))
    }
    
    func onLogoutSelected() {
        showLogoutAlert = true
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
