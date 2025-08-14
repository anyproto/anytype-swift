import Foundation
import SwiftUI

@MainActor
final class SettingsCoordinatorViewModel: ObservableObject,
                                    SettingsModuleOutput,
                                    AboutModuleOutput {
    
    @Injected(\.openedDocumentProvider)
    private var documentService: any OpenedDocumentsProviderProtocol
    @Injected(\.applicationStateService)
    private var applicationStateService: any ApplicationStateServiceProtocol
    
    @Published var showFileStorage = false
    @Published var showAppearance = false
    @Published var showPushNotificationsSettings = false
    @Published var showLogoutAlert = false
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
    
    func onNotificationsSelected() {
        showPushNotificationsSettings = true
    }
    
    func onFileStorageSelected() {
        showFileStorage = true
    }
    
    func onAboutSelected() {
        showAbout = true
    }
    
    func onAccountDataSelected() {
        showKeychainPhraseForSettings = true
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
