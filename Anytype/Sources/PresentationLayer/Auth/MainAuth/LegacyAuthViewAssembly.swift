import SwiftUI

final class LegacyAuthViewAssembly {
    
    // MARK: - DI
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    @MainActor
    func createAuthView() -> MainAuthView {
        let viewModel = MainAuthViewModel(applicationStateService: serviceLocator.applicationStateService())
        return MainAuthView(viewModel: viewModel)
    }
    
}
