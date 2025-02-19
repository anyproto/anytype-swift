import SwiftUI

@MainActor
protocol AuthViewModelOutput: AnyObject {
    func onJoinAction(state: JoinFlowState) -> AnyView
    func onLoginAction() -> AnyView
    func onSettingsAction() -> AnyView
}
