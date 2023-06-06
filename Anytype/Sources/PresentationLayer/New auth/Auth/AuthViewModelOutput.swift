import SwiftUI

@MainActor
protocol AuthViewModelOutput: AnyObject {
    
    func onJoinAction() -> AnyView
    func onUrlAction(_ url: URL)
}
