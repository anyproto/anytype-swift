import Foundation

@MainActor
protocol SpaceSwitchModuleOutput: AnyObject {
    func onSettingsSelected()
    func onCreateSpaceSelected()
}
