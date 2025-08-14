import Foundation
import SwiftUI

struct SettingsCoordinatorView: View {
    
    @StateObject private var model = SettingsCoordinatorViewModel()
    
    var body: some View {
        SettingsView(output: model)
            .sheet(isPresented: $model.showFileStorage) {
                FileStorageView()
            }
            .anytypeSheet(isPresented: $model.showAppearance) {
                SettingsAppearanceView()
            }
            .sheet(isPresented: $model.showPushNotificationsSettings) {
                PushNotificationsSettingsView()
            }
            .anytypeSheet(isPresented: $model.showLogoutAlert) {
                DashboardLogoutAlert {
                    model.onBackupTap()
                } onLogout: {
                    model.onLogoutConfirmTap()
                }
            }
            .anytypeSheet(isPresented: $model.showDeleteAccountAlert) {
                DashboardAccountDeletionAlert()
            }
            .sheet(isPresented: $model.showKeychainPhraseForLogout) {
                KeychainPhraseView(context: .logout)
            }
            .sheet(isPresented: $model.showKeychainPhraseForSettings) {
                KeychainPhraseView(context: .settings)
            }
            .sheet(isPresented: $model.showAbout) {
                AboutView(output: model)
                    .sheet(isPresented: $model.showDebugMenuForAbout) {
                        DebugMenuView()
                    }
            }
            .sheet(isPresented: $model.showDebugMenu) {
                DebugMenuView()
            }
            .sheet(isPresented: $model.showSpaceManager) {
                SpacesManagerView()
            }
            .sheet(isPresented: $model.showMembership) {
                MembershipCoordinator()
            }
            .sheet(item: $model.objectIconPickerData) {
                ObjectIconPicker(data: $0)
            }
            .sheet(isPresented: $model.showMySites) {
                PublishedSitesView()
            }
    }
}
