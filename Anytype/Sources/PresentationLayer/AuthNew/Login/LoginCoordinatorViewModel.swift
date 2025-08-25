import Foundation
import SwiftUI

@MainActor
final class LoginCoordinatorViewModel: ObservableObject, LoginOutput {
    
    @Published var showPublicDebugMenu = false
    @Published var showOpenSettingsURL = false
    
    @Published var migrationData: MigrationModuleData?
    @Published var secureAlertData: SecureAlertData?
    @Published var qrCodeScannerData: QrCodeScannerData?
    
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
