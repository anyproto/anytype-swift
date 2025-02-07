import Foundation

@MainActor
protocol SpaceSettingsModuleOutput: AnyObject {
    func onSpaceDetailsSelected()
    
    func onChangeIconSelected()
    func onRemoteStorageSelected()
    func onPersonalizationSelected()
    func onSpaceShareSelected()
    func onSpaceMembersSelected()
}
