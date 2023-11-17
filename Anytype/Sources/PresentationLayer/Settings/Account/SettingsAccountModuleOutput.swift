import Foundation

@MainActor
protocol SettingsAccountModuleOutput: AnyObject {
    func onRecoveryPhraseSelected()
    func onLogoutSelected()
    func onDeleteAccountSelected()
}
