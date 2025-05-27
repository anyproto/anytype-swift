import Foundation

@MainActor
protocol SpaceSettingsModuleOutput: AnyObject {
    func onWallpaperSelected()
    func onDefaultObjectTypeSelected()
    func onObjectTypesSelected()

    func onRemoteStorageSelected()
    func onSpaceShareSelected()
    func onSpaceMembersSelected()
    func onBinSelected()
}
