import SwiftUI

@MainActor
protocol AuthViewModelOutput: AnyObject {
    func onJoinAction() -> AnyView
    func onDebugMenuAction() -> AnyView
    func onUrlAction(_ url: URL)
}
