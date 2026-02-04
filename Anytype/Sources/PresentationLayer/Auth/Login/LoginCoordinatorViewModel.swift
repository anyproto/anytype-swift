import Foundation
import SwiftUI

@MainActor
@Observable
final class LoginCoordinatorViewModel: LoginOutput {

    var showPublicDebugMenu = false
    var showOpenSettingsURL = false

    var migrationData: MigrationModuleData?
    var secureAlertData: SecureAlertData?
    var qrCodeScannerData: QrCodeScannerData?
    
    // MARK: - LoginOutput
    
    func onOpenSettingsSelected() {
        showOpenSettingsURL = true
    }
    
    func onOpenPublicDebugMenuSelected() {
        showPublicDebugMenu = true
    }
    
    func onOpenQRCodeSelected(data: QrCodeScannerData) {
        qrCodeScannerData = data
    }
    
    func onOpenMigrationSelected(data: MigrationModuleData) {
        migrationData = data
    }
    
    func onOpenSecureAlertSelected(data: SecureAlertData) {
        secureAlertData = data
    }
}
