import Foundation
import SwiftUI

@MainActor
final class AuthCoordinatorViewModel: ObservableObject, PrimaryAuthOutput {
    
    @Published var showDebugMenu = false
    @Published var showSettings = false
    @Published var showLogin = false
    @Published var showJoinFlow = false
    
    var joinState: JoinFlowState?
    
    // MARK: - PrimaryAuthOutput
    
    func onJoinSelected(state: JoinFlowState) {
        joinState = state
        showJoinFlow = true
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
