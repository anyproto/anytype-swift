import Foundation

@MainActor
protocol SettingsAccountModuleOutput: AnyObject {
    func onRecoveryPhraseSelected()
    func onLogoutSelected()
    func onDeleteAccountSelected()
    func onClearCacheSelected()
    func onChangeIconSelected(objectId: String)
}
