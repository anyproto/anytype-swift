import Foundation

@MainActor
protocol NewSpaceSettingsModuleOutput: AnyObject {
    func onSpaceDetailsSelected()
    func onWallpaperSelected()
    func onDefaultObjectTypeSelected()

    func onRemoteStorageSelected()
    func onSpaceShareSelected()
    func onSpaceMembersSelected()
}
