import Foundation
import SwiftUI

@MainActor
@Observable
final class SettingsCoordinatorViewModel: SettingsModuleOutput,
                                          AboutModuleOutput {

    @ObservationIgnored @Injected(\.openedDocumentProvider)
    private var documentService: any OpenedDocumentsProviderProtocol
    @ObservationIgnored @Injected(\.applicationStateService)
    private var applicationStateService: any ApplicationStateServiceProtocol

    var showFileStorage = false
    var showAppearance = false
    var showPushNotificationsSettings = false
    var showLogoutAlert = false
    var showKeychainPhraseForLogout = false
    var showDeleteAccountAlert = false
    var showAbout = false
    var showDebugMenuForAbout = false
    var showDebugMenu = false
    var showSpaceManager = false
    var showMembership = false
    var showMySites = false
    var showExperimentalFeatures = false
    var showKeychainPhraseForSettings = false
    var showProfileQRCode = false
    var showAnyIdBottomSheet = false
    var objectIconPickerData: ObjectIconPickerData?

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
    
    func onMySitesSelected() {
        showMySites = true
    }
    
    func onExperimentalSelected() {
        showExperimentalFeatures = true
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

    func onProfileQRCodeSelected() {
        showProfileQRCode = true
    }

    func onAnyIdBadgeTapped() {
        showAnyIdBottomSheet = true
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
