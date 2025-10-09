import Foundation

@MainActor
protocol SpaceSettingsModuleOutput: AnyObject {
    func onWallpaperSelected()
    func onDefaultObjectTypeSelected()
    func onObjectTypesSelected()
    func onPropertiesSelected()

    func onRemoteStorageSelected()
    func onSpaceShareSelected(_ completion: @escaping () -> Void)
    func onNotificationsSelected()
    func onBinSelected()
    func onSpaceUxTypeSelected()
}
