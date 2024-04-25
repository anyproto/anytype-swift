import Foundation
import SwiftUI

struct SettingsCoordinatorView: View {
    
    @StateObject var model: SettingsCoordinatorViewModel
    
    var body: some View {
        SettingsView(output: model)
            .sheet(isPresented: $model.showFileStorage) {
                FileStorageView()
            }
            .anytypeSheet(isPresented: $model.showAppearance) {
                SettingsAppearanceView()
                    
            }
            .sheet(isPresented: $model.showSettingsAccount) {
                SettingsAccountView(output: model)
                    .anytypeSheet(isPresented: $model.showLogoutAlert) {
                        DashboardLogoutAlert {
                            model.onBackupTap()
                        } onLogout: {
                            model.onLogoutConfirmTap()
                        }
                    }
                    .sheet(isPresented: $model.showKeychainPhrase) {
                        KeychainPhraseView(context: .logout)
                    }
            }
    }
}
