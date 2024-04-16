import SwiftUI

@MainActor
protocol AuthViewModelOutput: AnyObject {
    func onJoinAction() -> AnyView
    func onLoginAction() -> AnyView
    func onSettingsAction() -> AnyView
}
