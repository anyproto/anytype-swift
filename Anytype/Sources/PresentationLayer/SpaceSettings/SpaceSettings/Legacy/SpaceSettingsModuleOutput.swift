import Foundation

@MainActor
protocol SpaceSettingsModuleOutput: AnyObject {    
    func onChangeIconSelected()
    func onRemoteStorageSelected()
    func onPersonalizationSelected()
    func onSpaceShareSelected()
    func onSpaceMembersSelected()
}
