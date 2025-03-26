import Foundation

@MainActor
protocol NewSpaceSettingsModuleOutput: AnyObject {
    func onWallpaperSelected()
    func onDefaultObjectTypeSelected()
    func onObjectTypesSelected()

    func onRemoteStorageSelected()
    func onSpaceShareSelected()
    func onSpaceMembersSelected()
    func onBinSelected()
}
