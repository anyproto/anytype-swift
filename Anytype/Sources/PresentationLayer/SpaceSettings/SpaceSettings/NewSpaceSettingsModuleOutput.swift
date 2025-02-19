import Foundation

@MainActor
protocol NewSpaceSettingsModuleOutput: AnyObject {
    func onWallpaperSelected()
    func onDefaultObjectTypeSelected()

    func onRemoteStorageSelected()
    func onSpaceShareSelected()
    func onSpaceMembersSelected()
}
