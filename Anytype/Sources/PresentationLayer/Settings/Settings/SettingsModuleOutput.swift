import Foundation

@MainActor
protocol SettingsModuleOutput: AnyObject {
    func onDebugMenuSelected()
    func onAppearanceSelected()
    func onNotificationsSelected()
    func onFileStorageSelected()
    func onAboutSelected()
    func onAccountDataSelected()
    func onChangeIconSelected(objectId: String, spaceId: String)
    func onSpacesSelected()
    func onMembershipSelected()
}
