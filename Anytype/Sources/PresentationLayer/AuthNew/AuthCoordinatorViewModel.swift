import Foundation
import SwiftUI

@MainActor
final class AuthCoordinatorViewModel: ObservableObject, PrimaryAuthOutput {
    
    @Published var showDebugMenu = false
    @Published var showSettings = false
    
    // MARK: - PrimaryAuthOutput
    
    func onJoinSelected(state: JoinFlowState) {
        // TODO
    }
    
    func onLoginSelected() {
        // TODO
    }
    
    func onSettingsSelected() {
        showSettings = true
    }
    
    func onDebugMenuSelected() {
        showDebugMenu = true
    }
}
