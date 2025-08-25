import Foundation
import SwiftUI

@MainActor
final class AuthCoordinatorViewModel: ObservableObject, PrimaryAuthOutput {
    
    @Published var showDebugMenu = false
    @Published var showSettings = false
    @Published var showLogin = false
    
    // MARK: - PrimaryAuthOutput
    
    func onJoinSelected(state: JoinFlowState) {
        // TODO
    }
    
    func onLoginSelected() {
        showLogin = true
    }
    
    func onSettingsSelected() {
        showSettings = true
    }
    
    func onDebugMenuSelected() {
        showDebugMenu = true
    }
}
