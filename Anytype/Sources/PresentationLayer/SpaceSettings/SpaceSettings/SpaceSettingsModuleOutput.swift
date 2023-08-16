import Foundation

@MainActor
protocol SpaceSettingsModuleOutput: AnyObject {
    func onChangeIconSelected(objectId: String)
    func onRemoteStorageSelected()
}
