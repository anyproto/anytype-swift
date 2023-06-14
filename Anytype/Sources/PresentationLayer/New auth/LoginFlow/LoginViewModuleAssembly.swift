import SwiftUI

protocol LoginViewModuleAssemblyProtocol {
    @MainActor
    func make() -> AnyView
}

final class LoginViewModuleAssembly: LoginViewModuleAssemblyProtocol {
    
    // MARK: - LoginViewModuleAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        return LoginView(
            model: LoginViewModel()
        ).eraseToAnyView()
    }
}
