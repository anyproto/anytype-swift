import SwiftUI

struct DashboardLogoutAlert: View {
    
    @StateObject private var model: DashboardLogoutAlertModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var callOnBackupTap = false
    
    init(onBackup: @escaping () -> Void, onLogout: @escaping () -> Void) {
        self._model = StateObject(wrappedValue: DashboardLogoutAlertModel(onBackup: onBackup, onLogout: onLogout))
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.Keychain.haveYouBackedUpYourKey,
            message: Loc.Keychain.Key.description,
            buttons: {
                BottomAlertButton(
                    text: Loc.backUpKey,
                    style: .secondary
                ) {
                    callOnBackupTap = true
                    dismiss()
                }
                
                BottomAlertButton(
                    text: Loc.logOut,
                    style: .warning
                ) {
                    try await model.onLogoutTap()
                }
            }
        )
        .onDisappear {
            // Fix swiftui navigation when we open next screen after dismiss that
            if callOnBackupTap {
                model.onBackupTap()
            }
        }
    }
}
