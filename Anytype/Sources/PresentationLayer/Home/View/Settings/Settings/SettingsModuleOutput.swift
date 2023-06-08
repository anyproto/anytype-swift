import Foundation

@MainActor
protocol SettingsModuleOutput: AnyObject {
    func onDebugMenuSelected()
    func onPersonalizationSelected()
    func onAppearanceSelected()
    func onFileStorageSelected()
    func onAboutSelected()
    func onAccountDataSelected()
    func onChangeIconSelected(objectId: String)
}
