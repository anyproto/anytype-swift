import Foundation

@MainActor
protocol SettingsModuleOutput: AnyObject {
    func onDebugMenuSelected()
    func onAppearanceSelected()
    func onFileStorageSelected()
    func onAboutSelected()
    func onAccountDataSelected()
    func onChangeIconSelected(objectId: String)
    func onSpacesSelected()
}
