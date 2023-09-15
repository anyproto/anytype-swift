import SwiftUI

protocol AuthModuleAssemblyProtocol {
    @MainActor
    func make(output: AuthViewModelOutput?) -> AnyView
}

final class AuthModuleAssembly: AuthModuleAssemblyProtocol {
    
    // MARK: - AuthModuleAssemblyProtocol
    
    @MainActor
    func make(output: AuthViewModelOutput?) -> AnyView {
        return AuthView(
            model: AuthViewModel(
                output: output
            )
        ).eraseToAnyView()
    }
}
