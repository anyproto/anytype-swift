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
    
    func onSettingsAction() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
