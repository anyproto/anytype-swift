import Foundation

@MainActor
protocol PrimaryAuthOutput: AnyObject {
    func onJoinSelected(state: JoinFlowState)
    func onLoginSelected()
    func onSettingsSelected()
    func onDebugMenuSelected()
}
