import Foundation
import SwiftUI

@MainActor
final class SettingsCoordinatorViewModel: ObservableObject,
                                    SettingsModuleOutput,
                                    SettingsAccountModuleOutput,
                                    AboutModuleOutput {
    
    @Injected(\.documentService)
    private var documentService: any OpenedDocumentsProviderProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: any ApplicationStateServiceProtocol
    
    @Published var showFileStorage = false
    @Published var showAppearance = false
    @Published var showLogoutAlert = false
    @Published var showSettingsAccount = false
    @Published var showKeychainPhraseForLogout = false
    @Published var showDeleteAccountAlert = false
    @Published var showAbout = false
    @Published var showDebugMenuForAbout = false
    @Published var showDebugMenu = false
    @Published var showSpaceManager = false
    @Published var showMembership = false
    @Published var showKeychainPhraseForSettings = false
    @Published var objectIconPickerData: ObjectIconPickerData?
    
    // MARK: - SettingsModuleOutput
    
    func onDebugMenuSelected() {
        showDebugMenu = true
    }
    
    func onAppearanceSelected() {
        showAppearance = true
    }
    
    func onFileStorageSelected() {
        showFileStorage = true
    }
    
    func onAboutSelected() {
        showAbout = true
    }
    
    func onAccountDataSelected() {
        showSettingsAccount = true
    }
    
    func onChangeIconSelected(objectId: String, spaceId: String) {
        let document = documentService.document(objectId: objectId, spaceId: spaceId, mode: .preview)
        objectIconPickerData = ObjectIconPickerData(document: document)
    }
    
    func onSpacesSelected() {
        showSpaceManager = true
    }
    
    func onMembershipSelected() {
        showMembership = true
    }
    
    func onBackupTap() {
        showKeychainPhraseForLogout = true
    }
    
    func onLogoutConfirmTap() {
        applicationStateService.state = .initial
    }
    
    // MARK: - SettingsAccountModuleOutput
    
    func onRecoveryPhraseSelected() {
        showKeychainPhraseForSettings = true
    }
    
    func onLogoutSelected() {
        showLogoutAlert = true
    }
    
    func onDeleteAccountSelected() {
        showDeleteAccountAlert = true
    }
    
    // MARK: - AboutModuleOutput
    
    func onDebugMenuForAboutSelected() {
        showDebugMenuForAbout = true
    }
}
