import Foundation
import SwiftUI

@MainActor
@Observable
final class AuthCoordinatorViewModel: PrimaryAuthOutput {

    var showDebugMenu = false
    var showSettings = false
    var showLogin = false
    var showJoinFlow = false

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
