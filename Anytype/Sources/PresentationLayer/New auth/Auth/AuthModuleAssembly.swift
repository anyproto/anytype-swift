import SwiftUI

protocol AuthModuleAssemblyProtocol {
    @MainActor
    func make(output: AuthViewModelOutput?) -> AnyView
}

final class AuthModuleAssembly: AuthModuleAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - AuthModuleAssemblyProtocol
    
    @MainActor
    func make(output: AuthViewModelOutput?) -> AnyView {
        return AuthView(
            model: AuthViewModel(
                viewControllerProvider: uiHelpersDI.viewControllerProvider(),
                output: output
            )
        ).eraseToAnyView()
    }
}
