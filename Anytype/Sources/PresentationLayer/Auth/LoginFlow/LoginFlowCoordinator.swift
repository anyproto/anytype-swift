import SwiftUI

@MainActor
protocol LoginFlowCoordinatorProtocol {
    func startFlow() -> AnyView
}

@MainActor
final class LoginFlowCoordinator: LoginFlowCoordinatorProtocol, LoginFlowOutput {
    
    
    // MARK: - LoginFlowCoordinatorProtocol
    
    func startFlow() -> AnyView {
        LoginView(output: self).eraseToAnyView()
    }
}
