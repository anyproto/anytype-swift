import SwiftUI

struct LoginCoordinatorView: View {
    
    @StateObject private var model: LoginCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    
    init() {
        self._model = StateObject(wrappedValue: LoginCoordinatorViewModel())
    }
    
    var body: some View {
        LoginView(output: model)
            .cameraPermissionAlert(isPresented: $model.showOpenSettingsURL)
            .sheet(isPresented: $model.showPublicDebugMenu) {
                PublicDebugMenuView()
            }
            .anytypeSheet(item: $model.secureAlertData) {
                SecureAlertView(data: $0)
            }
            .fullScreenCover(item: $model.migrationData) {
                MigrationCoordinatorView(data: $0)
            }
            .sheet(item: $model.qrCodeScannerData) { data in
                QrCodeScannerView(qrCode: data.entropy, error: data.error)
            }
    }
}
