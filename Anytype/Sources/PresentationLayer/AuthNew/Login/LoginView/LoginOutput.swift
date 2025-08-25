import Foundation

@MainActor
protocol LoginOutput: AnyObject {
    func onOpenSettingsSelected()
    func onOpenPublicDebugMenuSelected()
    func onOpenQRCodeSelected(data: QrCodeScannerData)
    func onOpenMigrationSelected(data: MigrationModuleData)
    func onOpenSecureAlertSelected(data: SecureAlertData)
}
