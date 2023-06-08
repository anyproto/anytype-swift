import SwiftUI

@MainActor
protocol AuthViewModelOutput: AnyObject {
    
    func onJoinAction() -> AnyView
    
}
