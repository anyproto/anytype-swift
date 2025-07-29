import Foundation

@MainActor
protocol SpaceHubModuleOutput: AnyObject {
    func onSelectCreateObject()
    func onSelectSpace(spaceId: String)
    func onOpenSpaceSettings(spaceId: String)
    func onSelectAppSettings()
}
